import Testing
@testable import SakeShops

@Suite("ShopListCoordinator")
struct ShopListCoordinatorTests {

    @Test func shopRowTapped_pushesShopDetailRoute() {
        let app = AppCoordinator(shopListService: StubShopListService())
        let coordinator = ShopListCoordinator(app: app, service: StubShopListService())
        let shop = makeSakeShop()

        coordinator.viewModel.shopRowTapped(shop)

        #expect(app.path == [.shopDetail(shop)])
    }
}
