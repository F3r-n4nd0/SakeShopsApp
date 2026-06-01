import Foundation

final class HomeCoordinator {
    private unowned let app: AppCoordinator

    init(app: AppCoordinator) {
        self.app = app
    }

    func showShopList() {
        app.push(AppRoute.shopList)
    }

    func showMap(latitude: Double, longitude: Double, label: String) {
        app.pushMap(latitude: latitude, longitude: longitude, label: label)
    }
}
