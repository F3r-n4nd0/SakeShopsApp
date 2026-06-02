import Foundation

@Observable
final class HomeViewModel {
    var onShowShopList: () -> Void = {}
    var onShowMap: (Double, Double, String) -> Void = { _, _, _ in }
    var onShowDetail: (SakeShop) -> Void = { _ in }

    func shopListButtonTapped() {
        onShowShopList()
    }

    func mapButtonTapped() {
        //TODO: hard code location for testing
        onShowMap(35.6762, 139.6503, "Tokyo")
    }

    func showDetailButtonTapped() {
        //TODO: hard code shop for testing
        let demo = SakeShop(
            name: "Hasegawa Saketen",
            description: "One of Tokyo's most respected sake retailers.",
            picture: nil,
            rating: 4.8,
            address: "1-2-6 Nihonbashi, Chuo-ku, Tokyo",
            coordinates: SakeShop.Coordinate(latitude: 35.6837, longitude: 139.7745),
            googleMapsLink: URL(string: "https://maps.google.com")!,
            website: URL(string: "https://www.hasegawasaketen.com")!
        )
        onShowDetail(demo)
    }
}
