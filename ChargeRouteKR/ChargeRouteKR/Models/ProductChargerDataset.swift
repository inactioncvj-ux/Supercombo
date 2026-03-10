import Foundation

struct ProductChargerDataset: Codable {
    let stationID: String
    let displayName: String
    let restAreaName: String
    let highwayName: String?
    let direction: String
    let lat: Double
    let lng: Double
    let isDcCombo: Bool
    let maxKw: Double?
    let operatorName: String?
    let status: String
    let detourCostScore: Double?
    let teslaCompatibilityScore: Double?
    let reliabilityScore: Double?

    enum CodingKeys: String, CodingKey {
        case stationID = "station_id"
        case displayName = "display_name"
        case restAreaName = "rest_area_name"
        case highwayName = "highway_name"
        case direction
        case lat, lng
        case isDcCombo = "is_dc_combo"
        case maxKw = "max_kw"
        case operatorName = "operator"
        case status
        case detourCostScore = "detour_cost_score"
        case teslaCompatibilityScore = "tesla_compatibility_score"
        case reliabilityScore = "reliability_score"
    }

    func asChargerStation() -> ChargerStation {
        ChargerStation(
            stationID: stationID,
            displayName: displayName,
            restAreaName: restAreaName,
            highwayName: highwayName,
            direction: direction,
            lat: lat,
            lng: lng,
            isDcCombo: isDcCombo,
            maxKw: maxKw,
            operatorName: operatorName,
            status: status
        )
    }
}
