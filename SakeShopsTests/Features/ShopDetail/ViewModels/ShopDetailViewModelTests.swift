import Testing
@testable import SakeShops

@Suite("ShopDetailViewModel")
@MainActor
struct ShopDetailViewModelTests {

    @Test func showOnMapButtonTapped_callsOnShowMap() {
        let viewModel = ShopDetailViewModel(shop: makeSakeShop())
        var called = false
        viewModel.onShowMap = { called = true }

        viewModel.showOnMapButtonTapped()

        #expect(called)
    }
}
