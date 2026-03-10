import Foundation

struct RouteRecommendationEngine {
    func recommend(chargers: [ChargerStation], input: RouteSimulationInput) -> [TripRecommendation] {
        let highwayChargers = chargers.filter { $0.isDcCombo && $0.status == "available" }
        let chosen = Array(highwayChargers.prefix(3))

        let coldPenalty = max(0, Int((10 - input.outsideTemp) * 0.35))
        let lowSocPenalty = max(0, Int((35 - input.currentSoc) * 0.18))
        let styleBonus: Int = {
            switch input.drivingStyle {
            case .balanced: return 0
            case .fast: return -2
            case .safe: return 5
            }
        }()

        return chosen.enumerated().map { index, station in
            let baseArrival = 24 - index * 3
            let arrival = max(6, baseArrival - coldPenalty - lowSocPenalty)
            let departure = departureSoc(for: input.drivingStyle, index: index)
            let finalSoc = max(5, 15 - coldPenalty - lowSocPenalty + styleBonus - index * 2)
            let minutes = chargeMinutes(for: input.drivingStyle, index: index)

            return TripRecommendation(
                station: station,
                arrivalSoc: arrival,
                departureSoc: departure,
                finalArrivalSoc: finalSoc,
                chargeMinutes: minutes,
                preheatHint: index == 0 ? "도착 25~30분 전 프리히팅 유도" : "도착 20분 전 프리히팅 유도",
                note: index == 0 ? "우선 추천 경로" : "대안 경로"
            )
        }
    }

    private func departureSoc(for style: DrivingStyle, index: Int) -> Int {
        switch style {
        case .balanced:
            return 58 - index
        case .fast:
            return 54 - index
        case .safe:
            return 62 - index
        }
    }

    private func chargeMinutes(for style: DrivingStyle, index: Int) -> Int {
        switch style {
        case .balanced:
            return 21 + index
        case .fast:
            return 18 + index
        case .safe:
            return 24 + index * 2
        }
    }
}
