import Foundation

struct SakeShop: Decodable, Identifiable, Sendable {
    var id: String { name }

    let name: String
    let description: String
    let picture: URL?
    let rating: Double
    let address: String
    let coordinates: Coordinate
    let googleMapsLink: URL
    let website: URL

    enum CodingKeys: String, CodingKey {
        case name, description, picture, rating, address, coordinates, website
        case googleMapsLink = "google_maps_link"
    }
}

extension SakeShop {
    struct Coordinate: Decodable, Sendable {
        let latitude: Double
        let longitude: Double

        init(from decoder: any Decoder) throws {
            var container = try decoder.unkeyedContainer()
            latitude = try container.decode(Double.self)
            longitude = try container.decode(Double.self)
        }
    }
}
