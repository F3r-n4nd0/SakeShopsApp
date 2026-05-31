import Foundation

struct ShopsEndpoint: Endpoint {
    let path = "/shops"
    let method = HTTPMethod.get
    let page: Int
    let pageSize: Int

    var queryItems: [URLQueryItem] {
        [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "page_size", value: "\(pageSize)")
        ]
    }
}
