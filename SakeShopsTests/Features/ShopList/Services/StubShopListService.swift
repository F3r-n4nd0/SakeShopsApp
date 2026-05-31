@testable import SakeShops

struct StubShopListService: ShopListServiceProtocol {
    var result: Result<[SakeShop], ShopListError> = .success([])

    func fetchShops(page: Int, pageSize: Int) async throws -> [SakeShop] {
        try result.get()
    }
}
