# ChargeRouteKR

SwiftUI / Xcode 기반 iPhone 앱 골격.

## 현재 상태
- SwiftUI 앱 구조 초안
- 샘플 충전 경로 추천 화면
- 샘플 충전소 JSON 포함

## Xcode에서 시작하는 법
1. Xcode에서 새 iOS App 프로젝트를 `ChargeRouteKR` 이름으로 생성
2. 이 디렉터리의 Swift 파일들을 프로젝트에 추가
3. `Resources/chargers.sample.json`를 앱 번들에 포함
4. 기본 생성된 ContentView/App 파일을 이 디렉터리 파일로 교체

## 다음 단계
- 실제 환경부 데이터 파이프라인 결과물 연결
- Tesla API 연동 계층 추가
- 추천 엔진 고도화
