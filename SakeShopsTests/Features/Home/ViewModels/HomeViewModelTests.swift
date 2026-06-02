import Testing
@testable import SakeShops

@Suite("HomeViewModel")
struct HomeViewModelTests {

    @Test func shopListButtonTapped_callsOnShowShopList() {
        let viewModel = HomeViewModel()
        var called = false
        viewModel.onShowShopList = { called = true }

        viewModel.shopListButtonTapped()

        #expect(called)
    }

    @Test func showDetailButtonTapped_callsOnShowDetail() {
        let viewModel = HomeViewModel()
        var capturedShop: SakeShop?
        viewModel.onShowDetail = { capturedShop = $0 }

        viewModel.showDetailButtonTapped()

        #expect(capturedShop?.name == "Hasegawa Saketen")
    }

    @Test func mapButtonTapped_callsOnShowMap() {
        let viewModel = HomeViewModel()
        var capturedLat: Double?
        var capturedLon: Double?
        var capturedLabel: String?
        viewModel.onShowMap = { lat, lon, label in
            capturedLat = lat
            capturedLon = lon
            capturedLabel = label
        }

        viewModel.mapButtonTapped()

        #expect(capturedLat == 35.6762)
        #expect(capturedLon == 139.6503)
        #expect(capturedLabel == "Tokyo")
    }
}
