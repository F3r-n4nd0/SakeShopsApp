import SwiftUI

@Observable
final class AppCoordinator {
    var path: [AppRoute] = [] {
        didSet { releaseStaleCoordinators() }
    }
    var sheet: AppSheet?

    private var _home: HomeCoordinator?
    private var _shopList: ShopListCoordinator?

    var home: HomeCoordinator {
        if _home == nil { _home = HomeCoordinator(app: self) }
        return _home!
    }

    var shopList: ShopListCoordinator {
        if _shopList == nil {
            let client = URLSessionHTTPClient(baseURL: URL(string: "https://api.sakeshops.com")!)
            _shopList = ShopListCoordinator(app: self, service: ShopListService(client: client))
        }
        return _shopList!
    }

    func mapCoordinator(for location: MapLocation) -> MapCoordinator {
        MapCoordinator(location: location)
    }

    func pushMap(latitude: Double, longitude: Double, label: String) {
        push(.map(MapLocation(latitude: latitude, longitude: longitude, label: label)))
    }

    func presentMap(latitude: Double, longitude: Double, label: String) {
        present(.map(MapLocation(latitude: latitude, longitude: longitude, label: label)))
    }

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeAll()
    }

    func reset() {
        path = []
        _home = nil
        _shopList = nil
    }

    private func releaseStaleCoordinators() {
        let shopListActive = path.contains {
            switch $0 {
            case .shopList, .shopDetail: return true
            case .map: return false
            }
        }
        if !shopListActive { _shopList = nil }
    }

    func present(_ sheet: AppSheet) {
        self.sheet = sheet
    }

    func dismiss() {
        sheet = nil
    }
}
