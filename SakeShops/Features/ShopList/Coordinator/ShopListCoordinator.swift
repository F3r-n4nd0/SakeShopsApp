import Foundation

final class ShopListCoordinator {
    private unowned let app: AppCoordinator
    let viewModel: ShopListViewModel

    init(app: AppCoordinator, service: any ShopListServiceProtocol) {
        self.app = app
        self.viewModel = ShopListViewModel(service: service)
        viewModel.onShowDetail = { [unowned self] shop in
            self.app.push(.shopDetail(shop))
        }
    }
}
