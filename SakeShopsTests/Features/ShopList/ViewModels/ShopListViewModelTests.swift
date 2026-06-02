import Testing
@testable import SakeShops

@Suite("ShopListViewModel")
@MainActor
struct ShopListViewModelTests {

    // MARK: - task()

    @Test func task_setsShops_onSuccess() async {
        let service = MutableShopListService()
        service.result = .success([makeSakeShop(name: "Shop A"), makeSakeShop(name: "Shop B")])
        let viewModel = ShopListViewModel(service: service)

        await viewModel.task()

        #expect(viewModel.shops.count == 2)
        #expect(viewModel.error == nil)
        #expect(viewModel.isLoading == false)
    }

    @Test func task_setsHasMore_whenPageIsFull() async {
        let service = MutableShopListService()
        service.result = .success(makeShops(count: 20))
        let viewModel = ShopListViewModel(service: service)

        await viewModel.task()

        #expect(viewModel.hasMore == true)
    }

    @Test func task_clearsHasMore_whenPageIsPartial() async {
        let service = MutableShopListService()
        service.result = .success(makeShops(count: 5))
        let viewModel = ShopListViewModel(service: service)

        await viewModel.task()

        #expect(viewModel.hasMore == false)
    }

    @Test func task_setsError_onFailure() async {
        let service = MutableShopListService()
        service.result = .failure(.fetchFailed(.invalidResponse))
        let viewModel = ShopListViewModel(service: service)

        await viewModel.task()

        #expect(viewModel.error != nil)
        #expect(viewModel.shops.isEmpty)
        #expect(viewModel.isLoading == false)
    }

    // MARK: - loadNextPage()

    @Test func loadNextPage_appendsShops_onSuccess() async {
        let service = MutableShopListService()
        service.result = .success(makeShops(count: 20))
        let viewModel = ShopListViewModel(service: service)
        await viewModel.task()

        service.result = .success([makeSakeShop(name: "Page 2 Shop")])
        await viewModel.loadNextPage()

        #expect(viewModel.shops.count == 21)
        #expect(viewModel.loadMoreError == nil)
    }

    @Test func loadNextPage_setsLoadMoreError_onFailure() async {
        let service = MutableShopListService()
        service.result = .success(makeShops(count: 20))
        let viewModel = ShopListViewModel(service: service)
        await viewModel.task()

        service.result = .failure(.fetchFailed(.invalidResponse))
        await viewModel.loadNextPage()

        #expect(viewModel.loadMoreError != nil)
        #expect(viewModel.shops.count == 20)
    }

    @Test func loadNextPage_doesNothing_whenNoMore() async {
        let service = MutableShopListService()
        service.result = .success(makeShops(count: 5))
        let viewModel = ShopListViewModel(service: service)
        await viewModel.task()
        #expect(viewModel.hasMore == false)

        service.result = .success([makeSakeShop(name: "Should not appear")])
        await viewModel.loadNextPage()

        #expect(viewModel.shops.count == 5)
    }

    // MARK: - shopRowAppeared()

    @Test func shopRowAppeared_triggersLoad_forLastShop() async throws {
        let service = MutableShopListService()
        service.result = .success(makeShops(count: 20))
        let viewModel = ShopListViewModel(service: service)
        await viewModel.task()

        service.result = .success([makeSakeShop(name: "Next Page Shop")])
        let lastShop = try #require(viewModel.shops.last)
        await viewModel.shopRowAppeared(lastShop)

        #expect(viewModel.shops.count == 21)
    }

    @Test func shopRowAppeared_doesNothing_forNonLastShop() async throws {
        let service = MutableShopListService()
        service.result = .success(makeShops(count: 20))
        let viewModel = ShopListViewModel(service: service)
        await viewModel.task()

        service.result = .success([makeSakeShop(name: "Should not appear")])
        let firstShop = try #require(viewModel.shops.first)
        await viewModel.shopRowAppeared(firstShop)

        #expect(viewModel.shops.count == 20)
    }
}

// MARK: - Test helpers

private final class MutableShopListService: ShopListServiceProtocol {
    var result: Result<[SakeShop], ShopListError> = .success([])

    func fetchShops(page: Int, pageSize: Int) async throws -> [SakeShop] {
        try result.get()
    }
}

private func makeShops(count: Int) -> [SakeShop] {
    (1...count).map { makeSakeShop(name: "Shop \($0)") }
}
