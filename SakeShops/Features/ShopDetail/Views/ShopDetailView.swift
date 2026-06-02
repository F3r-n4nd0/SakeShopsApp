import SwiftUI

struct ShopDetailView: View {
    let model: ShopDetailViewModel

    var body: some View {
        List {
            Section {
                LabeledContent("Rating", value: String(format: "%.1f", model.shop.rating))
                LabeledContent("Address", value: model.shop.address)
            }
            Section {
                Button("Show on Map") {
                    model.showOnMapButtonTapped()
                }
            }
        }
        .navigationTitle(model.shop.name)
    }
}
