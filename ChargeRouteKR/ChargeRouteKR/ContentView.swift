import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = TripPlannerViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    VehicleStatusCard(currentSoc: viewModel.currentSoc, outsideTemp: viewModel.outsideTemp, modelName: viewModel.selectedModel.rawValue)

                    TripInputCard(
                        origin: $viewModel.origin,
                        destination: $viewModel.destination,
                        currentSoc: $viewModel.currentSoc,
                        outsideTemp: $viewModel.outsideTemp,
                        selectedModel: $viewModel.selectedModel,
                        selectedStyle: $viewModel.selectedStyle,
                        onSimulate: { viewModel.simulate() }
                    )

                    RecommendationSection(recommendations: viewModel.recommendations)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("ChargeRoute KR")
        }
        .onAppear {
            viewModel.loadSampleDataIfNeeded()
            viewModel.simulate()
        }
    }
}

#Preview {
    ContentView()
}
