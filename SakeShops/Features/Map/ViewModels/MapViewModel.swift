import Foundation

@Observable
final class MapViewModel {
    let location: MapLocation

    init(location: MapLocation) {
        self.location = location
    }
}
