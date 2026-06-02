@testable import SakeShops

final class MutableShopListService: ShopListServiceProtocol {
    var result: Result<[SakeShop], ShopListError> = .success([])

    func fetchShops(page: Int, pageSize: Int) async throws -> [SakeShop] {
        try result.get()
    }
}

func makeShops(count: Int) -> [SakeShop] {
    (1...count).map { makeSakeShop(name: "Shop \($0)") }
}
