import Foundation

@Observable
@MainActor
final class ShopDetailViewModel {
    let shop: SakeShop
    var onShowMap: () -> Void = {}

    init(shop: SakeShop) {
        self.shop = shop
    }

    /// Apple Maps URL built from the shop's coordinates so the address link opens the native Maps app.
    var appleMapsURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "maps.apple.com"
        components.queryItems = [
            URLQueryItem(name: "ll", value: "\(shop.coordinates.latitude),\(shop.coordinates.longitude)"),
            URLQueryItem(name: "q", value: shop.name)
        ]
        // components.url is non-nil for a well-formed https URL with a valid host
        return components.url!
    }

    func showOnMapButtonTapped() {
        onShowMap()
    }
}
