# Tesla 공식 API / 공식 SDK 지원 기능 조사

작성일: 2026-03-10

## 목적
Tesla 공식 API와 Tesla가 공개한 공식 SDK(`vehicle-command`) 기준으로,
**현재 공식적으로 어떤 기능이 가능한지**를 정리한다.

이 문서는 특히 Supercombo처럼 Tesla 전용 앱을 설계할 때,
무엇을 공식 범위 안에서 기대할 수 있는지 파악하기 위한 기초 자료다.

---

## 조사 범위
이번 조사는 다음 자료를 중심으로 진행했다.

### 1. Tesla 공식 공개 저장소
- `teslamotors/vehicle-command`
- 공개 README
- CLI 명령 목록 (`cmd/tesla-control/commands.go`)
- 주요 기능 코드 (`pkg/vehicle/*.go`)
- protobuf 정의 (`car_server.proto`)

### 2. Tesla 개발자 문서 관련 공개 단서
- README 내 developer.tesla.com 링크
- 검색 스니펫으로 확인한 Fleet API / Tesla Support 정황

### 제한 사항
- Tesla 공식 사이트 일부는 fetch가 403으로 막혀 전체 원문 직접 검증에 한계가 있었다.
- 따라서 이 문서는 **공식 GitHub 저장소 + 공개적으로 확인 가능한 공식 문구 단서**를 중심으로 작성했다.

---

## 큰 그림
Tesla 공식 생태계는 크게 두 층으로 나뉜다.

### A. Fleet API
- Tesla 서버를 통한 공식 API 접근
- OAuth token 필요
- 서드파티 앱 사용자 인증 필요

### B. Vehicle Command SDK
- 차량 명령을 위한 새로운 command authentication 프로토콜
- 서버 인증(OAuth) + 차량 keychain 기반 명령 인증
- 공식 Go SDK 및 HTTP proxy 제공

즉 현재 Tesla는 예전 Owner API 스타일에서,
**Fleet API + vehicle-command 기반 구조**로 이동 중인 것으로 보인다.

---

## 공식 README에서 확인되는 핵심
공식 README 기준으로 확인되는 사항:

- Tesla vehicles now support a protocol that provides **end-to-end command authentication**
- 이 SDK는 climate control, charging 등 차량 기능 제어용
- HTTP proxy가 REST API 호출을 vehicle-command 프로토콜로 변환
- Owner API는 점차 종료되고, newer vehicles는 command authentication 기반으로 이동
- 명령 실행을 위해서는:
  1. 유효한 OAuth token
  2. 차량 keychain에 등록된 public key
  가 필요함

즉 서드파티 앱이 공식적으로 차량을 제어하려면,
단순 토큰 하나가 아니라 **사용자 인증 + 차량 측 키 등록**까지 필요하다.

---

## 공식적으로 확인되는 기능 범주

## 1. 차량 상태 조회
가능 범주가 분명하다.

공식 SDK 코드에서 보이는 state category:
- charge
- climate
- drive
- location
- closures
- charge-schedule
- precondition-schedule
- tire-pressure
- media
- media-detail
- software-update
- parental-controls

### 의미
공식 범위 안에서 적어도 다음 계열 정보는 읽을 수 있다.
- 충전 상태
- 공조 상태
- 주행 상태
- 위치 상태
- 도어/창문/잠금 등 closure 상태
- 충전/프리컨디셔닝 스케줄 상태
- 타이어 압력
- 미디어 상태
- 소프트웨어 업데이트 상태
- 부모 통제 상태

이건 Tesla 전용 앱을 만들 때 매우 중요한 기반이다.

---

## 2. 충전 관련 제어
공식 지원이 매우 뚜렷하다.

공식 SDK/CLI에서 확인되는 충전 관련 명령:
- `charging-set-limit`
- `charging-set-amps`
- `charging-start`
- `charging-stop`
- `charge-port-open`
- `charge-port-close`
- `charging-schedule-add`
- `charging-schedule-remove`
- `charging-schedule-cancel`

코드에서도 확인되는 것:
- ChargeStart
- ChargeStop
- ChangeChargeLimit
- SetChargingAmps
- AddChargeSchedule
- RemoveChargeSchedule

### 의미
공식 범위 안에서 **충전 상태 조절 / 충전 시작·중지 / 충전 스케줄 설정**은 분명히 가능하다.

---

## 3. 프리컨디셔닝 / 공조 관련 기능
공식적으로 일부 존재한다.

공식 CLI/코드에서 확인되는 항목:
- `climate-on`
- `climate-off`
- `climate-set-temp`
- `precondition-schedule-add`
- `precondition-schedule-remove`
- `auto-seat-and-climate`
- `seat-heater`
- `steering-wheel-heater`
- seat cooler 관련 기능

protobuf 레벨에서 확인되는 항목:
- `HvacSetPreconditioningMaxAction`
- `PreconditionSchedule`

### 의미
Tesla 공식 범위 안에 **프리컨디셔닝 관련 명령/스케줄**이 존재한다는 것은 분명하다.

### 하지만 중요한 주의점
현재 공개 자료만으로는 다음을 확정할 수 없다.
- 이것이 **실내 공조 중심 preconditioning**인지
- **배터리 preconditioning**까지 포함하는지
- **급속충전 전 배터리 예열**과 동일한지

즉 “프리컨디셔닝 관련 기능이 존재한다”는 건 확실하지만,
그 기능의 정확한 의미는 앱 설계에서 반드시 추가 검증이 필요하다.

---

## 4. 차량 제어 / 편의 기능
공식적으로 가능한 범위가 넓다.

확인된 명령 예:
- `lock`, `unlock`
- `honk`
- `flash-lights`
- `windows-vent`, `windows-close`
- `guest-mode-on/off`
- `valet-mode-on/off`
- `wake`
- `sentry-mode`
- `software-update-start/cancel`
- `set vehicle name`
- trunk/frunk/tonneau 관련 명령

### 의미
테슬라는 공식적으로도 꽤 많은 차량 원격 제어를 허용하고 있다.
이건 “자동 루틴 앱”, “스마트 알림 앱”, “원격 액션 시퀀서” 같은 아이디어의 기반이 된다.

---

## 5. 소프트웨어 업데이트 관련 기능
공식 지원이 보인다.

확인된 명령:
- `software-update-start`
- `software-update-cancel`
- software-update state category

### 의미
OTA 상태를 읽고, 일정 수준의 업데이트 동작을 제어하는 구조가 존재한다.
이건 Tesla OTA 인텔리전스 앱 아이디어와 연결될 수 있다.

---

## 6. Nearby Charging Sites
공식 protobuf에서 확인되는 항목:
- `GetNearbyChargingSites`

### 의미
Tesla 공식 프로토콜 안에 **근처 충전소 조회** 개념이 존재한다.

### 하지만 아직 불확실한 것
- 이 nearby charging sites가 어떤 충전소 범위를 포함하는가
- 슈퍼차저만 중심인지
- 서드파티 fast charger까지 어느 정도 포괄하는지

이건 Supercombo 입장에서 매우 중요한 후속 조사 포인트다.

---

## 7. 내비 / 목적지 전송 관련 기능
현재 공개 SDK에서 **명시적 navigation destination command**는 뚜렷하게 확인되지 않았다.

### 의미
- 차량에 목적지를 보내는 기능이 전혀 없다고 단정할 수는 없음
- 하지만 공식 공개 SDK/CLI에서 바로 쓰는 명령으로는 확인되지 않음

### 앱 설계에 주는 의미
- “차로 전송하기”는 Tesla 공식 앱에 존재하는 UX처럼 보이지만,
- 서드파티에 공개된 공식 명령/API 경로는 아직 명확하지 않다.

즉 이 영역은 **중요하지만 불확실**하다.

---

## 8. 서드파티 Fast Charger / 프리컨디셔닝 관련 공식 단서
검색 스니펫으로 확인된 Tesla Support 문구 정황:

> Third-party fast chargers that meet our performance and reliability standards may be added to Tesla's navigation automatically as Qualified Third-Party Chargers.

그리고:

> When drivers navigate to a Qualified Third-Party Charger, the battery automatically preconditions...

### 의미
이 정황이 맞다면 Tesla는 원칙적으로:
- 서드파티 급속충전기를 내비에 넣을 수 있고
- 일정 조건을 만족하면 battery preconditioning까지 연결할 수 있다.

### 하지만 주의
- 공식 원문 전체를 fetch로 직접 검증하지는 못했다.
- 다만 이 정황은 Supercombo 관점에서 매우 중요하다.

---

## 기능별 정리표

| 기능 영역 | 공식 지원 여부 | 비고 |
|---|---|---|
| 차량 상태 조회 | 높음 | charge, climate, drive, location 등 확인 |
| 충전 시작/중지/한도/전류 | 높음 | 공식 명령/코드 모두 확인 |
| 충전 스케줄 | 높음 | add/remove 가능 |
| 공조 on/off/온도 | 높음 | 공식 명령/코드 확인 |
| 시트/스티어링 휠 히터 | 높음 | 공식 명령 확인 |
| 프리컨디셔닝 스케줄 | 높음 | add/remove 확인 |
| 프리컨디셔닝 즉시 실행 의미 | 불확실 | 배터리/실내 중 정확한 의미 추가 검증 필요 |
| 잠금/도어/창문/밸렛/게스트 모드 | 높음 | 공식 명령 확인 |
| OTA 상태/시작/취소 | 높음 | 공식 명령 확인 |
| Nearby charging sites | 존재 | 범위/포함 충전소 종류는 불확실 |
| 목적지/내비 전송 | 불확실 | 공식 SDK에서 명시적 명령 확인 못 함 |
| 서드파티 fast charger battery preconditioning | 정황 존재 | Tesla Support 스니펫 기준, 공식 원문 직접 검증 필요 |

---

## Supercombo 입장에서 중요한 해석

### 확실히 가능한 기반
- 차량 상태 읽기
- 충전 상태 제어
- 공조/프리컨디셔닝 관련 일부 제어
- 충전 스케줄

### 아직 별도 검증이 필요한 핵심
- 차로 전송하기
- 경유지 전체 전송
- 전송된 목적지의 충전소 인식
- 실제 배터리 프리컨디셔닝 발동

즉 Supercombo는
**앱 자체는 충분히 공식 범위 안에서 많은 부분을 구현할 수 있지만, 킬러 포인트는 추가 검증이 필요한 구조**라고 볼 수 있다.

---

## 다른 Tesla 전용 앱 아이디어에 주는 시사점
이 조사로 보면 공식 범위 안에서 상대적으로 유리한 앱은:
- 자동 루틴 앱
- 스마트 알림 앱
- OTA 인텔리전스 앱
- 원격 액션 시퀀서
- 충전 관리 앱

반대로 여전히 어려운 영역은:
- 목적지 전송을 핵심으로 하는 앱
- 차량이 특정 목적지를 fast charger로 인식하게 만드는 앱
- 프리컨디셔닝 결과를 제품이 강하게 보장해야 하는 앱

---

## 최종 결론
Tesla 공식 API / 공식 SDK는 이미 생각보다 넓은 기능을 제공한다.

특히 공식 범위 안에서 확실히 가능한 것은:
- 차량 상태 조회
- 충전 제어
- 공조 제어
- 일부 프리컨디셔닝 관련 기능
- OTA 관련 상태/제어
- 다양한 차량 편의 기능 제어

하지만 다음은 여전히 핵심 검증 대상이다.
- 차로 전송하기
- 충전 목적지 인식
- 실제 배터리 프리컨디셔닝 발동

즉,
**공식 API는 충분히 강력하지만, Supercombo 같은 제품의 ‘마법 같은 경험’은 여전히 몇 개의 중요한 불확실성 위에 서 있다.**
