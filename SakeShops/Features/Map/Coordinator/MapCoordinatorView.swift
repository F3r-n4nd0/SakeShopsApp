import SwiftUI

struct MapCoordinatorView: View {
    @State private var coordinator: MapCoordinator

    init(location: MapLocation) {
        _coordinator = State(initialValue: MapCoordinator(location: location))
    }

    var body: some View {
        MapView(model: coordinator.viewModel)
    }
}
