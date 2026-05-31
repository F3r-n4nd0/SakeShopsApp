import Foundation
@testable import SakeShops

// MARK: - MockURLProtocol

final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

// MARK: - Test types

struct TestModel: Codable, Equatable {
    let id: Int
    let name: String
}

struct TestEndpoint: Endpoint {
    var path: String = "/test"
    var method: HTTPMethod = .get
    var headers: [String: String] = [:]
    var queryItems: [URLQueryItem] = []
    var body: (any Encodable)? = nil
}

// MARK: - Factories

func makeURLSessionClient(
    baseURL: URL = URL(string: "https://api.example.com")!
) -> URLSessionHTTPClient {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [MockURLProtocol.self]
    return URLSessionHTTPClient(baseURL: baseURL, session: URLSession(configuration: config))
}

func makeHTTPResponse(
    url: URL = URL(string: "https://api.example.com")!,
    statusCode: Int = 200
) -> HTTPURLResponse {
    HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
}

func makeSakeShopsData(count: Int = 1) -> Data {
    let shop = """
    {
        "name": "Test Shop",
        "description": "A test shop",
        "picture": null,
        "rating": 4.5,
        "address": "123 Test St",
        "coordinates": [35.6762, 139.6503],
        "google_maps_link": "https://maps.app.goo.gl/test",
        "website": "https://example.com"
    }
    """
    return Data("[\(Array(repeating: shop, count: count).joined(separator: ","))]".utf8)
}
