protocol HTTPClient: Sendable {
    func send<T: Decodable>(_ endpoint: some Endpoint) async throws -> T
}
