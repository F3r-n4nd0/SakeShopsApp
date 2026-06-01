import SwiftUI

struct ShopListView: View {
    let model: ShopListViewModel

    var body: some View {
        Group {
            if model.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = model.error {
                ContentUnavailableView(
                    "Failed to load",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error.localizedDescription)
                )
            } else {
                List(model.shops) { shop in
                    Button(shop.name) {
                        model.shopRowTapped(shop)
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
        .navigationTitle("Sake Shops")
        .navigationDestination(for: ShopListRoute.self) { route in
            switch route {
            case .detail(let shop):
                ShopDetailView(model: model.detailModel(for: shop))
            }
        }
        .task { await model.task() }
    }
}
