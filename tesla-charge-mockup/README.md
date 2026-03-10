# ChargeRoute KR Mockup

한국형 테슬라 충전 경로 추천 앱의 로컬 목업.

## 실행

```bash
cd tesla-charge-mockup
python3 server.py
```

브라우저에서 아래 주소 열기:

- http://127.0.0.1:8765

## 포함 내용
- 출발지/목적지/배터리/온도/차종 입력
- 샘플 기반 경유 충전소 추천
- 예상 도착 잔량 표시
- 프리히팅 권장 타이밍 표시
- 목업 경로 시각화

## 다음 단계
- Tesla 공식 API 연동
- 실제 한국 충전소 DB 연결
- 지도 API 연결
- 서버 계산 로직 고도화
