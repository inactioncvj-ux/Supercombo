#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
from pathlib import Path
from typing import Any, Dict, List


REQUIRED_KEYS = ['station_id', 'display_name', 'lat', 'lng', 'is_dc_combo', 'status']


def main() -> None:
    parser = argparse.ArgumentParser(description='Validate product-ready charger dataset')
    parser.add_argument('input', help='Product-ready JSON path')
    args = parser.parse_args()

    records: List[Dict[str, Any]] = json.loads(Path(args.input).read_text(encoding='utf-8'))
    station_ids = set()
    errors = []

    for idx, rec in enumerate(records, start=1):
        for key in REQUIRED_KEYS:
            if rec.get(key) in (None, ''):
                errors.append(f'#{idx} missing {key}')
        sid = rec.get('station_id')
        if sid in station_ids:
            errors.append(f'#{idx} duplicate station_id: {sid}')
        station_ids.add(sid)

    if errors:
        print('Validation failed:')
        for error in errors:
            print('-', error)
        raise SystemExit(1)

    print(f'Validation ok: {len(records)} records')


if __name__ == '__main__':
    main()
