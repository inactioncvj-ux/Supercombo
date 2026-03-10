import SwiftUI

struct RecommendationSection: View {
    let recommendations: [TripRecommendation]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("추천 충전 전략")
                .font(.headline)

            ForEach(recommendations) { item in
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.station.displayName)
                                .font(.headline)
                            Text(item.note)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text(item.station.direction)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(.green.opacity(0.15))
                            .clipShape(Capsule())
                    }

                    HStack {
                        metric("도착", "\(item.arrivalSoc)%")
                        metric("출발", "\(item.departureSoc)%")
                        metric("최종", "\(item.finalArrivalSoc)%")
                    }

                    Text("충전 \(item.chargeMinutes)분 · \(item.preheatHint)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 18))
            }
        }
    }

    private func metric(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
