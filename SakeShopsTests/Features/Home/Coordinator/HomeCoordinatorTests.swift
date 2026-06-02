import Testing
@testable import SakeShops

@Suite("HomeCoordinator")
@MainActor
struct HomeCoordinatorTests {

    @Test func shopListButtonTapped_pushesShopListRoute() {
        let app = AppCoordinator(shopListService: StubShopListService())
        let coordinator = HomeCoordinator(app: app)

        coordinator.viewModel.shopListButtonTapped()

        #expect(app.path == [.shopList])
    }

    @Test func mapButtonTapped_setsSheetRouteToMap() throws {
        let app = AppCoordinator(shopListService: StubShopListService())
        let coordinator = HomeCoordinator(app: app)

        coordinator.viewModel.mapButtonTapped()

        let route = try #require(app.sheetRoute)
        guard case .map(let location) = route else {
            Issue.record("Expected .map sheet route, got \(route)")
            return
        }
        #expect(location.label == "Tokyo")
    }
}
