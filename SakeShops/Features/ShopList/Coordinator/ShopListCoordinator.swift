import Foundation

final class ShopListCoordinator {
    private unowned let app: AppCoordinator
    let viewModel: ShopListViewModel

    init(app: AppCoordinator, service: any ShopListServiceProtocol) {
        self.app = app
        self.viewModel = ShopListViewModel(service: service)
        viewModel.onShowDetail = { [unowned self] shop in self.showDetail(for: shop) }
    }

    func detailModel(for shop: SakeShop) -> ShopDetailViewModel {
        ShopDetailViewModel(shop: shop, onShowMap: { [unowned self] in
            app.pushMap(
                latitude: shop.coordinates.latitude,
                longitude: shop.coordinates.longitude,
                label: shop.name
            )
        })
    }

    private func showDetail(for shop: SakeShop) {
        app.push(.shopDetail(shop))
    }
}
