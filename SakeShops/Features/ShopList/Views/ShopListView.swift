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
                        Button(shop.name) {
                            model.shopRowTapped(shop)
                        }
                        .foregroundStyle(.primary)
                        .task {
                            if shop == model.shops.last {
                                await model.loadNextPage()
                            }
                        }
                    }
                    if model.isLoadingMore {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    }
                }
            }
        }
        .navigationTitle("Sake Shops")
        .task { await model.task() }
    }
}
