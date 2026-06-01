import SwiftUI

@Observable
final class AppCoordinator {
    var path = NavigationPath()
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

    func pushMap(latitude: Double, longitude: Double, label: String) {
        push(AppRoute.map(MapLocation(latitude: latitude, longitude: longitude, label: label)))
    }

    func presentMap(latitude: Double, longitude: Double, label: String) {
        present(.map(MapLocation(latitude: latitude, longitude: longitude, label: label)))
    }

    func push(_ route: some Hashable) {
        path.append(route)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path.removeLast(path.count)
    }

    func present(_ sheet: AppSheet) {
        self.sheet = sheet
    }

    func dismiss() {
        sheet = nil
    }
}
