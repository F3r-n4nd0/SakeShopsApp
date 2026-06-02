import SwiftUI

struct AppCoordinatorView: View {
    @Bindable var coordinator: AppCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            HomeCoordinatorView(coordinator: coordinator.home)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .shopList:
                        ShopListCoordinatorView(coordinator: coordinator.shopList)
                    case .shopDetail(let shop):
                        ShopDetailCoordinatorView(app: coordinator, shop: shop)
                    case .map(let location):
                        MapCoordinatorView(location: location)
                    }
                }
                .sheet(item: $coordinator.sheetRoute) { route in
                    switch route {
                    case .map(let location):
                        MapCoordinatorView(location: location)
                    }
                }
        }
    }
}
