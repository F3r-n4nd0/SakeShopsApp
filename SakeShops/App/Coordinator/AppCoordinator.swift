import SwiftUI

@Observable
final class AppCoordinator {
    var path: [AppRoute] = [] {
        didSet { releaseStaleCoordinators() }
    }

    var sheetRoute: AppSheetRoute?

    private let shopListService: any ShopListServiceProtocol
    private var _home: HomeCoordinator?
    private var _shopList: ShopListCoordinator?

    init(shopListService: any ShopListServiceProtocol) {
        self.shopListService = shopListService
    }

    var home: HomeCoordinator {
        if _home == nil { _home = HomeCoordinator(app: self) }
        return _home!
    }

    var shopList: ShopListCoordinator {
        if _shopList == nil {
            _shopList = ShopListCoordinator(app: self, service: shopListService)
        }
        return _shopList!
    }

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func presentSheet(_ route: AppSheetRoute) {
        sheetRoute = route
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
    }

    private func releaseStaleCoordinators() {
        if !path.contains(.shopList) { _shopList = nil }
    }
}
