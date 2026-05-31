protocol ShopListServiceProtocol {
    func fetchShops(page: Int, pageSize: Int) async throws -> [SakeShop]
}

struct ShopListService: ShopListServiceProtocol {
    private let client: any HTTPClient

    init(client: any HTTPClient) {
        self.client = client
    }

    func fetchShops(page: Int, pageSize: Int) async throws -> [SakeShop] {
        do {
            return try await client.send(ShopsEndpoint(page: page, pageSize: pageSize))
        } catch let error as NetworkError {
            switch error {
            case .decoding(let decodingError):
                throw ShopListError.decodingFailed(decodingError)
            default:
                throw ShopListError.fetchFailed(error)
            }
        }
    }
}
