#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any, Dict, List


def load_records(path: Path) -> List[Dict[str, Any]]:
    return json.loads(path.read_text(encoding='utf-8'))


def slugify(text: str) -> str:
    cleaned = ''.join(ch if ch.isalnum() else '-' for ch in text.strip().lower())
    return '-'.join(part for part in cleaned.split('-') if part)


def derive_station_id(record: Dict[str, Any], idx: int) -> str:
    rest_area = record.get('rest_area_name_inferred') or record.get('station_name_raw') or f'station-{idx}'
    direction = record.get('direction_inferred') or 'unknown'
    return f"{slugify(str(rest_area))}-{slugify(str(direction))}"


def display_direction(direction: str) -> str:
    mapping = {
        'up': '상행/서울방향',
        'down': '하행/반대방향',
        'unknown': '방향미상',
    }
    return mapping.get(direction, direction)


def main() -> None:
    parser = argparse.ArgumentParser(description='Derive product-ready highway DC combo dataset')
    parser.add_argument('input', help='Normalized JSON path')
    parser.add_argument('--output', required=True, help='Output JSON path')
    args = parser.parse_args()

    records = load_records(Path(args.input))
    product = []
    for idx, rec in enumerate(records, start=1):
        if not rec.get('is_highway_candidate'):
            continue
        if not rec.get('is_dc_combo_candidate'):
            continue
        if rec.get('lat') is None or rec.get('lng') is None:
            continue

        rest_area = rec.get('rest_area_name_inferred') or rec.get('station_name_raw')
        direction = rec.get('direction_inferred') or 'unknown'
        highway_name = rec.get('highway_name_inferred')
        display_name = rec.get('station_name_raw') or rest_area

        product.append({
            'station_id': derive_station_id(rec, idx),
            'display_name': display_name,
            'rest_area_name': rest_area,
            'highway_name': highway_name,
            'direction': display_direction(direction),
            'lat': rec.get('lat'),
            'lng': rec.get('lng'),
            'is_dc_combo': True,
            'max_kw': rec.get('output_kw'),
            'operator': rec.get('operator_raw'),
            'status': rec.get('status'),
            'detour_cost_score': None,
            'tesla_compatibility_score': None,
            'reliability_score': None,
            'source_refs': [{
                'source': rec.get('source'),
                'source_station_id': rec.get('source_station_id'),
                'source_charger_id': rec.get('source_charger_id'),
            }],
        })

    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(product, ensure_ascii=False, indent=2), encoding='utf-8')
    print(f'Derived {len(product)} highway DC combo candidates -> {output_path}')


if __name__ == '__main__':
    main()
