import SwiftUI

struct AppCoordinatorView: View {
    @State private var coordinator: AppCoordinator

    init(coordinator: AppCoordinator) {
        _coordinator = State(initialValue: coordinator)
    }

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
        }
    }
}
