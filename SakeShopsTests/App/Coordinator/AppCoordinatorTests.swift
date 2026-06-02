import Testing
@testable import SakeShops

@Suite("AppCoordinator")
struct AppCoordinatorTests {

    // MARK: - Path management

    @Test func push_appendsRouteToPath() {
        let app = AppCoordinator(shopListService: StubShopListService())

        app.push(.shopList)

        #expect(app.path == [.shopList])
    }

    @Test func push_appendsMultipleRoutesInOrder() {
        let app = AppCoordinator(shopListService: StubShopListService())
        let shop = makeSakeShop()

        app.push(.shopList)
        app.push(.shopDetail(shop))

        #expect(app.path == [.shopList, .shopDetail(shop)])
    }

    @Test func pop_removesLastRoute() {
        let app = AppCoordinator(shopListService: StubShopListService())
        app.push(.shopList)
        app.push(.shopDetail(makeSakeShop()))

        app.pop()

        #expect(app.path == [.shopList])
    }

    @Test func pop_doesNothingOnEmptyPath() {
        let app = AppCoordinator(shopListService: StubShopListService())

        app.pop()

        #expect(app.path.isEmpty)
    }

    @Test func popToRoot_clearsAllRoutes() {
        let app = AppCoordinator(shopListService: StubShopListService())
        app.push(.shopList)
        app.push(.shopDetail(makeSakeShop()))

        app.popToRoot()

        #expect(app.path.isEmpty)
    }

    @Test func reset_clearsPath() {
        let app = AppCoordinator(shopListService: StubShopListService())
        app.push(.shopList)

        app.reset()

        #expect(app.path.isEmpty)
    }

    // MARK: - Coordinator lifecycle

    @Test func shopListCoordinator_isReleasedWhenRouteLeaves() {
        let app = AppCoordinator(shopListService: StubShopListService())
        app.push(.shopList)
        let first = app.shopList

        app.pop()

        let second = app.shopList
        #expect(first !== second)
    }

    @Test func shopListCoordinator_isRetainedWhileRouteIsInStack() {
        let app = AppCoordinator(shopListService: StubShopListService())
        app.push(.shopList)
        let first = app.shopList

        app.push(.shopDetail(makeSakeShop()))

        #expect(first === app.shopList)
    }

    @Test func reset_recyclesHomeCoordinator() {
        let app = AppCoordinator(shopListService: StubShopListService())
        let first = app.home

        app.reset()

        #expect(first !== app.home)
    }
}
