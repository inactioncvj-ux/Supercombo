import Foundation

struct RouteSimulationInput {
    let origin: String
    let destination: String
    let currentSoc: Double
    let outsideTemp: Double
    let vehicleModel: VehicleModel
    let drivingStyle: DrivingStyle
}
