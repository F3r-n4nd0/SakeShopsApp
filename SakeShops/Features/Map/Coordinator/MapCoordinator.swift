import Foundation

@MainActor
final class MapCoordinator {
    let viewModel: MapViewModel

    init(location: MapLocation) {
        self.viewModel = MapViewModel(location: location)
    }
}
