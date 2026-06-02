import Foundation

@Observable
@MainActor
final class ShopListViewModel {
    private(set) var shops: [SakeShop] = []
    private(set) var isLoading = false
    private(set) var isLoadingMore = false
    private(set) var error: ShopListError?
    private(set) var loadMoreError: ShopListError?
    private(set) var hasMore = true

    var onShowDetail: (SakeShop) -> Void = { _ in }

    private let service: any ShopListServiceProtocol
    private var currentPage = 1
    private let pageSize = 20

    init(service: any ShopListServiceProtocol) {
        self.service = service
    }

    func task() async {
        isLoading = true
        defer { isLoading = false }
        error = nil
        currentPage = 1
        hasMore = true
        do {
            let result = try await service.fetchShops(page: 1, pageSize: pageSize)
            shops = result
            hasMore = result.count == pageSize
        } catch let e as ShopListError {
            error = e
        } catch {}
    }

    func loadNextPage() async {
        guard !isLoadingMore, !isLoading, hasMore else { return }
        isLoadingMore = true
        loadMoreError = nil
        defer { isLoadingMore = false }
        let nextPage = currentPage + 1
        do {
            let result = try await service.fetchShops(page: nextPage, pageSize: pageSize)
            shops += result
            currentPage = nextPage
            hasMore = result.count == pageSize
        } catch let e as ShopListError {
            loadMoreError = e
        } catch {}
    }

    func shopRowTapped(_ shop: SakeShop) {
        onShowDetail(shop)
    }
}
