import SwiftUI

struct HomeView: View {
    let coordinator: HomeCoordinator

    var body: some View {
        List {
            Button("Sake Shops") {
                coordinator.showShopList()
            }
            Button("Map") {
                coordinator.showMap(latitude: 35.6762, longitude: 139.6503, label: "Tokyo")
            }
        }
        .navigationTitle("Home")
    }
}

#Preview {
    HomeView(coordinator: HomeCoordinator(app: AppCoordinator()))
}
