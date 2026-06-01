import SwiftUI

struct AppCoordinatorView: View {
    @State private var coordinator = AppCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            HomeCoordinatorView(coordinator: coordinator.home)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .shopList:
                        ShopListCoordinatorView(coordinator: coordinator.shopList)
                    case .shopDetail(let shop):
                        ShopDetailView(model: coordinator.shopList.detailModel(for: shop))
                    case .map(let location):
                        MapCoordinatorView(coordinator: coordinator.mapCoordinator(for: location))
                    }
                }
        }
        .sheet(item: $coordinator.sheet) { sheet in
            switch sheet {
            case .map(let location):
                MapCoordinatorView(coordinator: coordinator.mapCoordinator(for: location))
            }
        }
    }
}
