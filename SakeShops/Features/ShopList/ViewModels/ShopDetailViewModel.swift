import Foundation

@Observable
final class ShopDetailViewModel {
    let shop: SakeShop
    var onShowMap: () -> Void = {}

    init(shop: SakeShop, onShowMap: @escaping () -> Void) {
        self.shop = shop
        self.onShowMap = onShowMap
    }

    func showOnMapButtonTapped() {
        onShowMap()
    }
}
