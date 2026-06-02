import Foundation

final class HomeCoordinator {
    private unowned let app: AppCoordinator
    let viewModel: HomeViewModel

    init(app: AppCoordinator) {
        self.app = app
        self.viewModel = HomeViewModel()
        viewModel.onShowShopList = { [unowned self] in
            self.app.push(.shopList)
        }
        viewModel.onShowMap = { [unowned self] lat, lon, label in
            self.app.push(.map(MapLocation(latitude: lat, longitude: lon, label: label)))
        }
        viewModel.onShowDetail = { [unowned self] shop in
            self.app.push(.shopDetail(shop))
        }
    }
}
