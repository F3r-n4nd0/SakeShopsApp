import Foundation

struct AuthenticatedHTTPClient: HTTPClient {
    private let base: any HTTPClient
    private let tokenProvider: any TokenProvider

    init(base: any HTTPClient, tokenProvider: any TokenProvider) {
        self.base = base
        self.tokenProvider = tokenProvider
    }

    func send<T: Decodable>(_ endpoint: some Endpoint) async throws -> T {
        let token = try await tokenProvider.token()
        return try await base.send(AuthorizedEndpoint(endpoint, token: token))
    }
}

private struct AuthorizedEndpoint<Wrapped: Endpoint>: Endpoint {
    private let wrapped: Wrapped
    private let token: String

    init(_ wrapped: Wrapped, token: String) {
        self.wrapped = wrapped
        self.token = token
    }

    var path: String { wrapped.path }
    var method: HTTPMethod { wrapped.method }
    var queryItems: [URLQueryItem] { wrapped.queryItems }
    var body: (any Encodable)? { wrapped.body }
    var headers: [String: String] {
        var h = wrapped.headers
        h["Authorization"] = "Bearer \(token)"
        return h
    }
}
