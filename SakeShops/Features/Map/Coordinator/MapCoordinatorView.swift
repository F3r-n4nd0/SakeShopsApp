import SwiftUI

struct MapCoordinatorView: View {
    let coordinator: MapCoordinator

    var body: some View {
        MapView(model: coordinator.viewModel)
    }
}
