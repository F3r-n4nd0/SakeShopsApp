import Foundation

@Observable
@MainActor
final class HomeViewModel {
    var onShowShopList: () -> Void = {}
    var onShowMap: (MapLocation) -> Void = { _ in }

    func shopListButtonTapped() {
        onShowShopList()
    }

    func mapButtonTapped() {
        onShowMap(MapLocation(latitude: 35.6762, longitude: 139.6503, label: "Tokyo"))
    }
}
