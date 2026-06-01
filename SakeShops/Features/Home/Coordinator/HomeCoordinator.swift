import Foundation

final class HomeCoordinator {
    private unowned let app: AppCoordinator
    let viewModel: HomeViewModel

    init(app: AppCoordinator) {
        self.app = app
        self.viewModel = HomeViewModel()
        viewModel.onShowShopList = { [unowned self] in
            self.showShopList()
        }
        viewModel.onShowMap = { [unowned self] lat, lon, label in
            self.showMap(latitude: lat, longitude: lon, label: label)
        }
    }

    private func showShopList() {
        app.push(AppRoute.shopList)
    }
    
    private func showMap(latitude: Double, longitude: Double, label: String) {
        app.pushMap(latitude: latitude, longitude: longitude, label: label)
    }
}
