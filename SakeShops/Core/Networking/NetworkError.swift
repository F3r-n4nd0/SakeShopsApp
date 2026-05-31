import Foundation
enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case statusCode(Int, Data)
    case decoding(DecodingError)
    case underlying(any Error)
}
