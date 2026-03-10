import Foundation

struct TripRecommendation: Identifiable, Hashable {
    let id = UUID()
    let station: ChargerStation
    let arrivalSoc: Int
    let departureSoc: Int
    let finalArrivalSoc: Int
    let chargeMinutes: Int
    let preheatHint: String
    let note: String
}

enum VehicleModel: String, CaseIterable, Identifiable {
    case modelYLongRange = "Model Y Long Range"
    case model3LongRange = "Model 3 Long Range"
    case modelYRWD = "Model Y RWD"

    var id: String { rawValue }
}

enum DrivingStyle: String, CaseIterable, Identifiable {
    case balanced = "균형형"
    case fast = "고속 우선"
    case safe = "안전 잔량 우선"

    var id: String { rawValue }
}
