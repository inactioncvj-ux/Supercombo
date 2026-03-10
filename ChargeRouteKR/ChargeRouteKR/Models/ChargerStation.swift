import Foundation

struct ChargerStation: Codable, Identifiable, Hashable {
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

    var id: String { stationID }

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
    }
}
