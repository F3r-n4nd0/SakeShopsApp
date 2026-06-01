import SwiftUI

struct HomeCoordinatorView: View {
    let coordinator: HomeCoordinator

    var body: some View {
        HomeView(model: coordinator.viewModel)
    }
}
