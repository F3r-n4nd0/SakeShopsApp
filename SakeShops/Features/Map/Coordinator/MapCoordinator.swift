import Foundation

final class MapCoordinator {
    let viewModel: MapViewModel

    init(location: MapLocation) {
        self.viewModel = MapViewModel(location: location)
    }
}
