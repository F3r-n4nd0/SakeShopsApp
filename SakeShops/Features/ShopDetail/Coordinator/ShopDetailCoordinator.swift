import Foundation

@MainActor
final class ShopDetailCoordinator {
    private unowned let app: AppCoordinator
    let viewModel: ShopDetailViewModel

    init(app: AppCoordinator, shop: SakeShop) {
        self.app = app
        viewModel = ShopDetailViewModel(shop: shop)
        viewModel.onShowMap = { [unowned self] in
            self.app.presentSheet(.map(MapLocation(
                latitude: shop.coordinates.latitude,
                longitude: shop.coordinates.longitude,
                label: shop.name
            )))
        }
    }
}
