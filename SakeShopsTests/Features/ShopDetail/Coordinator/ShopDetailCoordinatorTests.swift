import Testing
@testable import SakeShops

@Suite("ShopDetailCoordinator")
@MainActor
struct ShopDetailCoordinatorTests {

    @Test func showOnMapButtonTapped_pushesMapRouteWithShopCoordinates() throws {
        let app = AppCoordinator(shopListService: StubShopListService())
        let shop = makeSakeShop(coordinates: SakeShop.Coordinate(latitude: 34.6937, longitude: 135.5023))
        let coordinator = ShopDetailCoordinator(app: app, shop: shop)

        coordinator.viewModel.showOnMapButtonTapped()

        let route = try #require(app.path.first)
        guard case .map(let location) = route else {
            Issue.record("Expected .map route, got \(route)")
            return
        }
        #expect(location.latitude == 34.6937)
        #expect(location.longitude == 135.5023)
        #expect(location.label == shop.name)
    }
}
