import Testing
import Foundation
@testable import SakeShops

@Suite("URLSessionHTTPClient", .serialized)
struct URLSessionHTTPClientTests {
    let baseURL = URL(string: "https://api.example.com")!
    let client: URLSessionHTTPClient

    init() {
        client = makeURLSessionClient(baseURL: URL(string: "https://api.example.com")!)
    }

    @Test func decodesSuccessResponse() async throws {
        let expected = TestModel(id: 1, name: "Test")
        MockURLProtocol.requestHandler = { [baseURL] _ in
            (makeHTTPResponse(url: baseURL), try JSONEncoder().encode(expected))
        }

        let result: TestModel = try await client.send(TestEndpoint())
        #expect(result == expected)
    }

    @Test func throwsStatusCodeError_onHTTPError() async throws {
        MockURLProtocol.requestHandler = { [baseURL] _ in
            (makeHTTPResponse(url: baseURL, statusCode: 404), Data())
        }

        do {
            let _: TestModel = try await client.send(TestEndpoint())
            Issue.record("Expected NetworkError.statusCode to be thrown")
        } catch NetworkError.statusCode(let code, _) {
            #expect(code == 404)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func throwsDecodingError_onInvalidJSON() async throws {
        MockURLProtocol.requestHandler = { [baseURL] _ in
            (makeHTTPResponse(url: baseURL), Data("not json".utf8))
        }

        do {
            let _: TestModel = try await client.send(TestEndpoint())
            Issue.record("Expected NetworkError.decoding to be thrown")
        } catch NetworkError.decoding {
            // expected
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func throwsUnderlyingError_onConnectionFailure() async throws {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        do {
            let _: TestModel = try await client.send(TestEndpoint())
            Issue.record("Expected NetworkError.underlying to be thrown")
        } catch NetworkError.underlying {
            // expected
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func includesQueryItems_inRequestURL() async throws {
        let items = [URLQueryItem(name: "page", value: "1"), URLQueryItem(name: "limit", value: "20")]
        var capturedURL: URL?

        MockURLProtocol.requestHandler = { request in
            capturedURL = request.url
            return (makeHTTPResponse(url: request.url!), try JSONEncoder().encode(TestModel(id: 0, name: "")))
        }

        let _: TestModel = try await client.send(TestEndpoint(queryItems: items))

        let components = try #require(capturedURL.flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) })
        #expect(components.queryItems == items)
    }

    @Test func includesCustomHeaders_inRequest() async throws {
        var capturedHeaders: [String: String]?

        MockURLProtocol.requestHandler = { request in
            capturedHeaders = request.allHTTPHeaderFields
            return (makeHTTPResponse(url: request.url!), try JSONEncoder().encode(TestModel(id: 0, name: "")))
        }

        let _: TestModel = try await client.send(TestEndpoint(headers: ["X-API-Key": "secret"]))
        #expect(capturedHeaders?["X-API-Key"] == "secret")
    }

    @Test func setsContentTypeHeader_forPostWithBody() async throws {
        var capturedContentType: String?

        MockURLProtocol.requestHandler = { request in
            capturedContentType = request.value(forHTTPHeaderField: "Content-Type")
            return (makeHTTPResponse(url: request.url!), try JSONEncoder().encode(TestModel(id: 0, name: "")))
        }

        let _: TestModel = try await client.send(TestEndpoint(method: .post, body: TestModel(id: 1, name: "Body")))
        #expect(capturedContentType == "application/json")
    }
}
