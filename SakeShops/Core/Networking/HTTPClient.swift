// docs/adr/0004-networking-architecture.md
protocol HTTPClient: Sendable {
    func send<T: Decodable>(_ endpoint: some Endpoint) async throws -> T
}
