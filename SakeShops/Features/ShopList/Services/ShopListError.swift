enum ShopListError: Error {
    case fetchFailed(NetworkError)
    case decodingFailed(DecodingError)
}
