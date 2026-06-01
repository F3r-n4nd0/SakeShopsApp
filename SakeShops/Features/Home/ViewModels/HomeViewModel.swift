import Foundation

@Observable
final class HomeViewModel {
    var onShowShopList: () -> Void = {}
    var onShowMap: (Double, Double, String) -> Void = { _, _, _ in }

    func shopListButtonTapped() {
        onShowShopList()
    }

    func mapButtonTapped() {
        onShowMap(35.6762, 139.6503, "Tokyo")
    }
}
