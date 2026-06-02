import SwiftUI

struct ShopDetailCoordinatorView: View {
    @State private var coordinator: ShopDetailCoordinator

    init(app: AppCoordinator, shop: SakeShop) {
        _coordinator = State(initialValue: ShopDetailCoordinator(app: app, shop: shop))
    }

    var body: some View {
        ShopDetailView(model: coordinator.viewModel)
    }
}
