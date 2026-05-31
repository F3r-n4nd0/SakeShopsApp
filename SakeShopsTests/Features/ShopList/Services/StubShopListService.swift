@testable import SakeShops

struct StubShopListService: ShopListServiceProtocol {
    var result: Result<[SakeShop], ShopListError> = .success([])

    func fetchShops() async throws -> [SakeShop] {
        try result.get()
    }
}
