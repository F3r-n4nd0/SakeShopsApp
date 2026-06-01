import Foundation

@Observable
final class ShopListViewModel {
    private(set) var shops: [SakeShop] = []
    private(set) var isLoading = false
    private(set) var error: ShopListError?

    var onShowDetail: (SakeShop) -> Void = { _ in }
    var onShowMap: (Double, Double, String) -> Void = { _, _, _ in }

    private let service: any ShopListServiceProtocol

    init(service: any ShopListServiceProtocol) {
        self.service = service
    }

    func task() async {
        isLoading = true
        defer { isLoading = false }
        error = nil
        do {
            shops = try await service.fetchShops(page: 1, pageSize: 20)
        } catch let e as ShopListError {
            error = e
        } catch {}
    }

    func shopRowTapped(_ shop: SakeShop) {
        onShowDetail(shop)
    }

    func detailModel(for shop: SakeShop) -> ShopDetailViewModel {
        ShopDetailViewModel(shop: shop, onShowMap: { [self] in
            onShowMap(shop.coordinates.latitude, shop.coordinates.longitude, shop.name)
        })
    }
}
