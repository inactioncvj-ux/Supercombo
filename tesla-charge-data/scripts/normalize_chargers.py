#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
import json
import re
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional

HIGHWAY_KEYWORDS = [
    '고속도로', '휴게소', '하이패스', 'ex', '한국도로공사'
]
DC_COMBO_KEYWORDS = ['dc콤보', 'dc combo', 'combo', '콤보']
FAST_KEYWORDS = ['급속', 'fast']
DIRECTION_PATTERNS = [
    ('서울방향', 'up'),
    ('부산방향', 'down'),
    ('상행', 'up'),
    ('하행', 'down'),
    ('인천방향', 'up'),
    ('목포방향', 'down'),
    ('순천방향', 'down'),
    ('대전방향', 'down'),
]
HIGHWAY_PATTERNS = [
    '경부고속도로',
    '영동고속도로',
    '중부고속도로',
    '서해안고속도로',
    '남해고속도로',
    '호남고속도로',
    '천안논산고속도로',
    '중부내륙고속도로',
    '중앙고속도로',
    '동해고속도로',
]


def load_records(path: Path) -> List[Dict[str, Any]]:
    suffix = path.suffix.lower()
    if suffix == '.json':
        data = json.loads(path.read_text(encoding='utf-8'))
        if isinstance(data, list):
            return [r for r in data if isinstance(r, dict)]
        if isinstance(data, dict):
            for key in ('data', 'items', 'records', 'result'):
                value = data.get(key)
                if isinstance(value, list):
                    return [r for r in value if isinstance(r, dict)]
        raise ValueError(f'Unsupported JSON shape: {path}')
    if suffix == '.csv':
        with path.open('r', encoding='utf-8-sig', newline='') as f:
            return list(csv.DictReader(f))
    raise ValueError(f'Unsupported file type: {path}')


def pick(record: Dict[str, Any], *keys: str) -> Optional[Any]:
    lowered = {str(k).lower(): v for k, v in record.items()}
    for key in keys:
        if key in record and record[key] not in (None, ''):
            return record[key]
        lk = key.lower()
        if lk in lowered and lowered[lk] not in (None, ''):
            return lowered[lk]
    return None


def parse_float(value: Any) -> Optional[float]:
    if value in (None, ''):
        return None
    try:
        return float(str(value).strip())
    except ValueError:
        return None


def parse_kw(value: Any) -> Optional[float]:
    if value in (None, ''):
        return None
    text = str(value).lower().replace('kw', '').strip()
    m = re.search(r'\d+(?:\.\d+)?', text)
    return float(m.group(0)) if m else None


def normalize_status(value: Any) -> str:
    text = str(value or '').strip().lower()
    if any(x in text for x in ['운영', '사용가능', '정상', 'available', 'ready']):
        return 'available'
    if any(x in text for x in ['점검', '고장', '중지', '불가', 'unavailable', 'fault']):
        return 'unavailable'
    return 'unknown'


def bool_keyword(value: Any, keywords: Iterable[str]) -> bool:
    text = str(value or '').strip().lower()
    return any(k.lower() in text for k in keywords)


def infer_direction(*values: Any) -> str:
    joined = ' '.join(str(v or '') for v in values)
    for token, normalized in DIRECTION_PATTERNS:
        if token in joined:
            return normalized
    return 'unknown'


def infer_highway_name(*values: Any) -> Optional[str]:
    joined = ' '.join(str(v or '') for v in values)
    for token in HIGHWAY_PATTERNS:
        if token in joined:
            return token
    return None


def infer_rest_area_name(station_name: Any, address: Any) -> Optional[str]:
    text = str(station_name or '')
    m = re.search(r'([가-힣A-Za-z0-9]+휴게소)', text)
    if m:
        return m.group(1)
    text = str(address or '')
    m = re.search(r'([가-힣A-Za-z0-9]+휴게소)', text)
    if m:
        return m.group(1)
    return None


def normalize_record(record: Dict[str, Any], source: str) -> Dict[str, Any]:
    station_name = pick(record, 'station_name', 'stationName', '충전소명', 'statNm', 'name')
    operator = pick(record, 'operator', 'operator_name', '운영기관', 'busiNm')
    address = pick(record, 'address', 'addr', '주소', 'zscode')
    lat = pick(record, 'lat', 'latitude', '위도')
    lng = pick(record, 'lng', 'longitude', '경도')
    charger_type = pick(record, 'charger_type', 'type', '충전기타입', 'chgerType')
    output_kw = pick(record, 'output_kw', '출력', 'power', 'output')
    status = pick(record, 'status', '상태', 'stat')
    updated_at = pick(record, 'updated_at', '갱신시각', 'lastTs', 'datetime')
    source_station_id = pick(record, 'station_id', 'statId', 'id')
    source_charger_id = pick(record, 'charger_id', 'chgerId')

    normalized = {
        'source': source,
        'source_station_id': str(source_station_id) if source_station_id is not None else None,
        'source_charger_id': str(source_charger_id) if source_charger_id is not None else None,
        'station_name_raw': station_name,
        'operator_raw': operator,
        'address_raw': address,
        'lat': parse_float(lat),
        'lng': parse_float(lng),
        'charger_type_raw': charger_type,
        'output_kw_raw': output_kw,
        'output_kw': parse_kw(output_kw),
        'status_raw': status,
        'status': normalize_status(status),
        'updated_at_raw': updated_at,
        'is_dc_combo_candidate': bool_keyword(charger_type, DC_COMBO_KEYWORDS),
        'is_fast_candidate': bool_keyword(charger_type, FAST_KEYWORDS) or (parse_kw(output_kw) or 0) >= 40,
        'is_highway_candidate': bool_keyword(station_name, HIGHWAY_KEYWORDS)
            or bool_keyword(address, HIGHWAY_KEYWORDS)
            or bool_keyword(operator, HIGHWAY_KEYWORDS),
        'rest_area_name_inferred': infer_rest_area_name(station_name, address),
        'direction_inferred': infer_direction(station_name, address),
        'highway_name_inferred': infer_highway_name(station_name, address),
    }
    return normalized


def main() -> None:
    parser = argparse.ArgumentParser(description='Normalize public EV charger data')
    parser.add_argument('input', help='Input JSON/CSV file')
    parser.add_argument('--source', default='env', help='Source label, e.g. env')
    parser.add_argument('--output', required=True, help='Output JSON path')
    args = parser.parse_args()

    input_path = Path(args.input)
    output_path = Path(args.output)
    records = load_records(input_path)
    normalized = [normalize_record(record, args.source) for record in records]
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(normalized, ensure_ascii=False, indent=2), encoding='utf-8')
    print(f'Normalized {len(normalized)} records -> {output_path}')


if __name__ == '__main__':
    main()
