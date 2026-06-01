import SwiftUI

struct ShopListCoordinatorView: View {
    let coordinator: ShopListCoordinator

    var body: some View {
        ShopListView(model: coordinator.viewModel)
    }
}
