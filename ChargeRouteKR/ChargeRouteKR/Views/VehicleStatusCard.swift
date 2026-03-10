import SwiftUI

struct VehicleStatusCard: View {
    let currentSoc: Double
    let outsideTemp: Double
    let modelName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("현재 차량 상태")
                .font(.headline)
            HStack {
                statusBlock(title: "배터리", value: "\(Int(currentSoc))%")
                statusBlock(title: "외기온도", value: "\(Int(outsideTemp))℃")
                statusBlock(title: "차종", value: modelName)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.blue.gradient.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    private func statusBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
