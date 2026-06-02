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
                List {
                    ForEach(model.shops) { shop in
                        Button {
                            model.shopRowTapped(shop)
                        } label: {
                            ShopRowView(shop: shop)
                        }
                        .foregroundStyle(.primary)
                    }
                    if model.isLoadingMore {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    } else if let error = model.loadMoreError {
                        Text(error.localizedDescription)
                            .foregroundStyle(.secondary)
                            .font(.footnote)
                            .listRowSeparator(.hidden)
                    }
                }
                .onScrollGeometryChange(for: Bool.self) { geo in
                    geo.contentOffset.y + geo.containerSize.height >=
                        geo.contentSize.height - geo.contentInsets.bottom - 200
                } action: { wasNearBottom, isNearBottom in
                    if !wasNearBottom, isNearBottom { Task { await model.loadNextPage() } }
                }
            }
        }
        .navigationTitle("Sake Shops")
        .task { await model.task() }
    }
}

