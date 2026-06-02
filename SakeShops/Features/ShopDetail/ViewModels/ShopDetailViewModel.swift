import Foundation

@Observable
final class ShopDetailViewModel {
    let shop: SakeShop
    var onShowMap: () -> Void = {}

    init(shop: SakeShop) {
        self.shop = shop
    }

    func showOnMapButtonTapped() {
        onShowMap()
    }
}
