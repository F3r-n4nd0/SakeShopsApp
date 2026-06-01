import SwiftUI

struct AppCoordinatorView: View {
    @State private var coordinator = AppCoordinator()

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            HomeView(coordinator: coordinator.home)
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .shopList:
                        ShopListView(model: coordinator.shopList.viewModel)
                    case .map(let location):
                        MapView(location: location)
                    }
                }
        }
        .sheet(item: $coordinator.sheet) { sheet in
            switch sheet {
            case .map(let location):
                MapView(location: location)
            }
        }
    }
}
