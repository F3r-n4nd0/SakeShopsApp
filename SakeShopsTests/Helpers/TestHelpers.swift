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

func makeSakeShop(
    name: String = "Test Shop",
    coordinates: SakeShop.Coordinate = SakeShop.Coordinate(latitude: 35.0, longitude: 139.0)
) -> SakeShop {
    SakeShop(
        name: name,
        description: "A test sake shop",
        picture: nil,
        rating: 4.5,
        address: "1-1 Test Street",
        coordinates: coordinates,
        googleMapsLink: URL(string: "https://maps.google.com")!,
        website: URL(string: "https://example.com")!
    )
}

func makeSakeShopsData(count: Int = 1) -> Data {
    let url = Bundle(for: MockURLProtocol.self).url(forResource: "shops", withExtension: "json")!
    let all = try! JSONSerialization.jsonObject(with: Data(contentsOf: url)) as! [[String: Any]]
    return try! JSONSerialization.data(withJSONObject: Array(all.prefix(count)))
}
