import Foundation

final class TripPlannerViewModel: ObservableObject {
    @Published var origin: String = "서울"
    @Published var destination: String = "부산"
    @Published var currentSoc: Double = 62
    @Published var outsideTemp: Double = 4
    @Published var selectedModel: VehicleModel = .modelYLongRange
    @Published var selectedStyle: DrivingStyle = .balanced
    @Published var recommendations: [TripRecommendation] = []

    private let dataLoader = ChargerDataLoader()
    private let engine = RouteRecommendationEngine()
    private var chargers: [ChargerStation] = []

    func loadSampleDataIfNeeded() {
        guard chargers.isEmpty else { return }
        chargers = dataLoader.loadBundledChargers()
    }

    func simulate() {
        let input = RouteSimulationInput(
            origin: origin,
            destination: destination,
            currentSoc: currentSoc,
            outsideTemp: outsideTemp,
            vehicleModel: selectedModel,
            drivingStyle: selectedStyle
        )
        recommendations = engine.recommend(chargers: chargers, input: input)
    }
}
