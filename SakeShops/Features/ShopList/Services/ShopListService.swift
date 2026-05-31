protocol ShopListServiceProtocol {
    func fetchShops() async throws -> [SakeShop]
}

struct ShopListService: ShopListServiceProtocol {
    private let client: any HTTPClient

    init(client: any HTTPClient) {
        self.client = client
    }

    func fetchShops() async throws -> [SakeShop] {
        do {
            return try await client.send(ShopsEndpoint())
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
