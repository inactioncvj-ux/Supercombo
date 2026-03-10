# Tesla 한국형 충전 앱 데이터 파이프라인 설계

작성일: 2026-03-10

## 목적
환경부/공공데이터를 원천으로 사용해,
**한국 고속도로 DC콤보 충전소를 앱에서 바로 사용할 수 있는 형태로 정제하는 데이터 파이프라인**을 설계한다.

---

## 1. 원칙

### 원천 데이터 원칙
- **환경부/무공해차 누리집/공공데이터포털 데이터**를 1차 원천으로 사용한다.
- 초기부터 수동 입력 DB가 아니라 **공공데이터 기반**으로 시작한다.
- 단, 앱에는 원본을 그대로 쓰지 않고 **정규화된 제품용 데이터셋**을 사용한다.

### 제품 데이터 원칙
앱이 필요한 것은 단순 충전기 목록이 아니라:
- 고속도로 휴게소 경유 가능 여부
- DC콤보 여부
- 상/하행 구분
- 경로상 우회 비용
- 실제 추천 엔진에서 바로 쓰는 좌표/속성
이다.

---

## 2. 데이터 레이어 구조

### Layer 0 — Raw Source
원천 데이터 원본 보관

예상 소스:
- 환경부 충전소 데이터
- 공공데이터포털 EV 충전기 데이터
- 도로공사/휴게소 관련 공개 데이터 (있다면 보강)

저장 형식:
- `data/raw/YYYY-MM-DD/*.json`
- `data/raw/YYYY-MM-DD/*.csv`

목적:
- 원본 보존
- 재처리 가능성 확보
- 변환 오류 발생 시 추적 가능

### Layer 1 — Normalized Charger Records
원본 필드명을 정규화한 1차 표준 포맷

예시 필드:
- `source`
- `source_station_id`
- `station_name_raw`
- `operator_raw`
- `address_raw`
- `lat`
- `lng`
- `charger_type_raw`
- `output_kw_raw`
- `status_raw`
- `updated_at_raw`

목적:
- 소스별 상이한 필드명 통합
- 후속 정제 로직의 입력 포맷 표준화

### Layer 2 — Highway Charger Candidates
고속도로/휴게소/DC콤보 후보만 추린 제품 후보군

추가 필드:
- `is_highway_candidate`
- `rest_area_name`
- `highway_name`
- `direction`
- `is_dc_combo`
- `is_fast_charge`
- `max_kw`
- `station_group_key`

목적:
- 제품에 필요한 subset 생성
- 일반 도심 충전소 제거

### Layer 3 — Product Ready Charger Dataset
앱 추천 엔진이 직접 사용하는 최종 데이터셋

추가 필드:
- `station_id`
- `normalized_name`
- `rest_area_name_normalized`
- `highway_name_normalized`
- `direction_normalized`
- `detour_cost_score`
- `tesla_compatibility_score`
- `reliability_score`
- `display_name`

목적:
- 추천 엔진 및 UI에서 바로 사용
- 중복 제거/표준화/후처리 완료

---

## 3. 권장 폴더 구조

```text
project/
  data/
    raw/
      2026-03-10/
        env-chargers.json
    normalized/
      chargers.normalized.json
    derived/
      highway-dc-combo.json
      highway-dc-combo-product.json
  scripts/
    import_env_data.py
    normalize_chargers.py
    derive_highway_chargers.py
    validate_chargers.py
  docs/
    data-dictionary.md
```

---

## 4. 정규화 스키마 초안

### 4.1 Normalized Charger Schema
```json
{
  "source": "env",
  "source_station_id": "string",
  "source_charger_id": "string",
  "station_name_raw": "string",
  "operator_raw": "string",
  "address_raw": "string",
  "lat": 37.123,
  "lng": 127.123,
  "charger_type_raw": "DC콤보",
  "output_kw_raw": "100",
  "status_raw": "운영중",
  "updated_at_raw": "2026-03-10T07:00:00+09:00"
}
```

### 4.2 Product Ready Schema
```json
{
  "station_id": "restarea_gyeongbu_chupungryeong_up_01",
  "display_name": "추풍령휴게소(서울방향) DC콤보",
  "rest_area_name": "추풍령휴게소",
  "highway_name": "경부고속도로",
  "direction": "상행",
  "lat": 36.216,
  "lng": 128.004,
  "is_dc_combo": true,
  "max_kw": 100,
  "operator": "환경부",
  "status": "available",
  "detour_cost_score": 0.12,
  "tesla_compatibility_score": 0.85,
  "reliability_score": null,
  "source_refs": [
    {
      "source": "env",
      "source_station_id": "abc123"
    }
  ]
}
```

---

## 5. 처리 단계

### Step 1. 수집(Import)
목표:
- 환경부/공공데이터 원본 수집

처리:
- API 호출 또는 공식 다운로드 파일 수집
- 원본 그대로 `data/raw/<date>/`에 저장
- 수집 메타데이터 기록

로그 항목:
- 수집 시각
- 소스 URL
- 응답 상태
- 레코드 수
- 파일 checksum

### Step 2. 정규화(Normalize)
목표:
- 다양한 원본 필드명을 공통 스키마로 변환

처리:
- 문자열 trim
- null/빈값 정리
- 좌표 숫자형 변환
- 출력(kW) 파싱
- 상태값 표준화

예:
- `운영중`, `사용가능`, `정상` → `available`
- `점검중`, `고장`, `중지` → `unavailable`

### Step 3. 필터링(Filter)
목표:
- 제품 대상 subset만 추출

조건:
- 급속 충전기 우선
- DC콤보 포함
- 고속도로/휴게소 후보 우선
- 좌표 누락 제거

방법:
- 주소/명칭 기반 고속도로 키워드 매칭
- 휴게소명 사전 매칭
- 도로공사 휴게소 목록과 조인 가능하면 조인

### Step 4. 그룹핑/중복 제거(Deduplicate)
목표:
- 같은 휴게소/같은 충전소 중복 정리

기준 후보:
- 휴게소명 + 방향 + 좌표 반경
- station name similarity
- source station id

산출:
- station_group_key 생성
- 여러 charger record를 한 station으로 묶기

### Step 5. 제품용 파생 필드 생성(Derive)
목표:
- 추천 엔진이 바로 쓸 수 있는 필드 생성

파생 필드:
- `station_id`
- `display_name`
- `direction_normalized`
- `detour_cost_score`
- `tesla_compatibility_score`
- `route_priority`

### Step 6. 검증(Validate)
목표:
- 깨진 데이터가 앱에 들어가지 않도록 함

검증 규칙:
- 위도/경도 존재
- `is_dc_combo == true`
- 방향값 허용 범위 내
- 휴게소명/고속도로명 존재
- 중복 station_id 없음

---

## 6. 방향/휴게소 정규화 전략

### 방향 정규화
원본 방향 표기가 제각각일 수 있다.
예:
- 상행 / 하행
- 서울방향 / 부산방향
- 양방향

내부 표준:
- `up`
- `down`
- `both`
- `unknown`

표시용 라벨은 별도로 유지:
- `서울방향`
- `부산방향`

### 휴게소명 정규화
예:
- `추풍령휴게소(서울방향)`
- `추풍령 휴게소 상행`
- `추풍령(상)`

정규화 결과:
- `rest_area_name`: `추풍령휴게소`
- `direction`: `up`

---

## 7. 추천 엔진용 핵심 필드
추천 로직이 최소한 필요로 하는 것:

- `station_id`
- `lat`, `lng`
- `highway_name`
- `direction`
- `is_dc_combo`
- `max_kw`
- `status`
- `detour_cost_score`
- `tesla_compatibility_score`

후속 확장 필드:
- `reliability_score`
- `user_reports_count`
- `avg_actual_kw`
- `queue_risk_score`

---

## 8. 운영 전략

### 초기 운영
- 매일 또는 주기적으로 raw 데이터 수집
- 정규화 스크립트 실행
- derived dataset 생성
- 앱은 derived dataset만 읽음

### 장애 대응
- 외부 API 실패 시 마지막 정상 derived dataset 사용
- raw source checksum 비교로 변경 감지
- 파싱 실패 레코드는 quarantine 파일로 분리

---

## 9. 구현 우선순위

### P0
- 환경부 원본 수집기
- 정규화 스키마
- 고속도로 DC콤보 필터
- 제품용 JSON 출력

### P1
- 휴게소/상하행 정규화
- 중복 제거
- detour score 계산

### P2
- 충전소 신뢰도 점수
- 실제 사용 데이터 병합
- 혼잡도/출력 실측 반영

---

## 10. 한 줄 결론
이 앱의 충전소 데이터 전략은
**‘공공데이터 원본 → 정규화 → 고속도로 DC콤보 subset → 제품용 추천 데이터셋’**
구조로 가는 것이 맞다.
