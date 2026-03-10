import SwiftUI

struct TripInputCard: View {
    @Binding var origin: String
    @Binding var destination: String
    @Binding var currentSoc: Double
    @Binding var outsideTemp: Double
    @Binding var selectedModel: VehicleModel
    @Binding var selectedStyle: DrivingStyle
    let onSimulate: () -> Void

    private let origins = ["서울", "판교", "대전", "대구"]
    private let destinations = ["부산", "강릉", "광주", "전주"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("주행 조건")
                .font(.headline)

            Picker("출발지", selection: $origin) {
                ForEach(origins, id: \.self) { Text($0).tag($0) }
            }
            .pickerStyle(.menu)

            Picker("목적지", selection: $destination) {
                ForEach(destinations, id: \.self) { Text($0).tag($0) }
            }
            .pickerStyle(.menu)

            VStack(alignment: .leading) {
                Text("현재 배터리: \(Int(currentSoc))%")
                Slider(value: $currentSoc, in: 10...100, step: 1)
            }

            VStack(alignment: .leading) {
                Text("외기온도: \(Int(outsideTemp))℃")
                Slider(value: $outsideTemp, in: -15...35, step: 1)
            }

            Picker("차종", selection: $selectedModel) {
                ForEach(VehicleModel.allCases) { model in
                    Text(model.rawValue).tag(model)
                }
            }
            .pickerStyle(.menu)

            Picker("운전 스타일", selection: $selectedStyle) {
                ForEach(DrivingStyle.allCases) { style in
                    Text(style.rawValue).tag(style)
                }
            }
            .pickerStyle(.segmented)

            Button(action: onSimulate) {
                Text("추천 경로 시뮬레이션")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
