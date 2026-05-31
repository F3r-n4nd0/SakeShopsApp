import Testing
import Foundation
@testable import SakeShops

@Suite("AuthenticatedHTTPClient")
struct AuthenticatedHTTPClientTests {
    @Test func injectsAuthorizationHeader() async throws {
        let spy = SpyHTTPClient()
        let client = await AuthenticatedHTTPClient(base: spy, tokenProvider: StubTokenProvider(token: "abc123"))

        let _: [SakeShop] = try await client.send(TestEndpoint())

        #expect(spy.capturedHeaders["Authorization"] == "Bearer abc123")
    }

    @Test func preservesExistingEndpointHeaders() async throws {
        let spy = SpyHTTPClient()
        var endpoint = TestEndpoint()
        endpoint.headers = ["X-Custom": "value"]
        let client = await AuthenticatedHTTPClient(base: spy, tokenProvider: StubTokenProvider(token: "tok"))

        let _: [SakeShop] = try await client.send(endpoint)

        #expect(spy.capturedHeaders["X-Custom"] == "value")
        #expect(spy.capturedHeaders["Authorization"] == "Bearer tok")
    }

    @Test func throwsWhenTokenProviderFails() async throws {
        let spy = SpyHTTPClient()
        let client = await AuthenticatedHTTPClient(
            base: spy,
            tokenProvider: StubTokenProvider(error: TokenError.expired)
        )

        await #expect(throws: TokenError.expired) {
            let _: [SakeShop] = try await client.send(TestEndpoint())
        }
    }

    @Test func forwardsBaseClientErrors() async throws {
        let stub = StubHTTPClient()
        stub.result = .failure(.invalidResponse)
        let client = await AuthenticatedHTTPClient(base: stub, tokenProvider: StubTokenProvider(token: "tok"))

        do {
            let _: [SakeShop] = try await client.send(TestEndpoint())
            Issue.record("Expected NetworkError.invalidResponse to be thrown")
        } catch NetworkError.invalidResponse {
            // expected
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}

// MARK: - Test helpers

private enum TokenError: Error, Equatable {
    case expired
}

private struct StubTokenProvider: TokenProvider {
    private let result: Result<String, any Error>

    init(token: String) { result = .success(token) }
    init(error: any Error) { result = .failure(error) }

    func token() async throws -> String { try result.get() }
}

private final class SpyHTTPClient: HTTPClient, @unchecked Sendable {
    var capturedHeaders: [String: String] = [:]

    func send<T: Decodable>(_ endpoint: some Endpoint) async throws -> T {
        capturedHeaders = endpoint.headers
        return try JSONDecoder().decode(T.self, from: makeSakeShopsData())
    }
}
