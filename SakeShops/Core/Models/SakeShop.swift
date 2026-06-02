import Foundation

struct SakeShop: Decodable, Hashable, Identifiable, Sendable {
    var id: String { name } // docs/adr/0003-sake-shop-identity.md

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
    struct Coordinate: Decodable, Hashable, Sendable {
        let latitude: Double
        let longitude: Double

        init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }

        init(from decoder: any Decoder) throws {
            var container = try decoder.unkeyedContainer()
            latitude = try container.decode(Double.self)
            longitude = try container.decode(Double.self)
        }
    }
}
