import Foundation
@testable import SakeShops

final class StubHTTPClient: HTTPClient, @unchecked Sendable {
    var result: Result<Data, NetworkError> = .failure(.invalidResponse)
    private let decoder: JSONDecoder

    init(decoder: JSONDecoder = JSONDecoder()) {
        self.decoder = decoder
    }

    func send<T: Decodable>(_ endpoint: some Endpoint) async throws -> T {
        let data = try result.get()
        do {
            return try decoder.decode(T.self, from: data)
        } catch let error as DecodingError {
            throw NetworkError.decoding(error)
        } catch {
            throw NetworkError.underlying(error)
        }
    }
}
