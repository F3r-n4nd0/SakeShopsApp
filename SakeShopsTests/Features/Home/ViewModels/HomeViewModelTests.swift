import Testing
@testable import SakeShops

@Suite("HomeViewModel")
@MainActor
struct HomeViewModelTests {

    @Test func shopListButtonTapped_callsOnShowShopList() {
        let viewModel = HomeViewModel()
        var called = false
        viewModel.onShowShopList = { called = true }

        viewModel.shopListButtonTapped()

        #expect(called)
    }

    @Test func mapButtonTapped_callsOnShowMap() {
        let viewModel = HomeViewModel()
        var capturedLocation: MapLocation?
        viewModel.onShowMap = { capturedLocation = $0 }

        viewModel.mapButtonTapped()

        #expect(capturedLocation?.latitude == 35.6762)
        #expect(capturedLocation?.longitude == 139.6503)
        #expect(capturedLocation?.label == "Tokyo")
    }
}
