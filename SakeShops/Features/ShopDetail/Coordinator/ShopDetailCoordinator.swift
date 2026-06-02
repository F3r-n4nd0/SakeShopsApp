import Foundation

final class ShopDetailCoordinator {
    private unowned let app: AppCoordinator
    let viewModel: ShopDetailViewModel

    init(app: AppCoordinator, shop: SakeShop) {
        self.app = app
        viewModel = ShopDetailViewModel(shop: shop)
        viewModel.onShowMap = {
            app.pushMap(
                latitude: shop.coordinates.latitude,
                longitude: shop.coordinates.longitude,
                label: shop.name
            )
        }
    }
}
