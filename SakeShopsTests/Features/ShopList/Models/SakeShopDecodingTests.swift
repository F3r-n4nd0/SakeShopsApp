import Testing
import Foundation
@testable import SakeShops

@Suite
struct SakeShopDecodingTests {
    let decoder = JSONDecoder()

    private func shopsData() throws -> Data {
        let url = try #require(Bundle(for: MockURLProtocol.self).url(forResource: "shops", withExtension: "json"))
        return try Data(contentsOf: url)
    }

    @Test func decodesAllShops() throws {
        let shops = try decoder.decode([SakeShop].self, from: shopsData())
        #expect(shops.count == 7)
    }

    @Test func decodesFields() throws {
        let shops = try decoder.decode([SakeShop].self, from: shopsData())
        let first = try #require(shops.first)
        #expect(first.name == "信州スシサカバ 寿しなの")
        #expect(first.rating == 4.0)
        #expect(first.coordinates.latitude == 36.644257)
        #expect(first.coordinates.longitude == 138.18668)
    }

    @Test func decodesNullPicture() throws {
        let shops = try decoder.decode([SakeShop].self, from: shopsData())
        let midori = try #require(shops.first { $0.name == "Midori Nagano" })
        #expect(midori.picture == nil)
    }
}
