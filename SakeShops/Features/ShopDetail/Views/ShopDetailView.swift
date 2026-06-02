import SwiftUI

struct ShopDetailView: View {
    let model: ShopDetailViewModel

    var body: some View {
        List {
            pictureSection
            infoSection
            actionsSection
        }
        .navigationTitle(model.shop.name)
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private var pictureSection: some View {
        if let picture = model.shop.picture {
            Section {
                AsyncImage(url: picture) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity)
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 220)
                .clipped()
                .listRowInsets(EdgeInsets())
            }
        }
    }
 
    private var infoSection: some View {
        Section {
            Text(model.shop.description)
                .foregroundStyle(.secondary)
            StarRatingView(rating: model.shop.rating)
            Link(destination: model.appleMapsURL) {
                Label(model.shop.address, systemImage: "mappin.and.ellipse")
            }
        }
    }

    private var actionsSection: some View {
        Section {
            Link("Visit Website", destination: model.shop.website)
            Button("Show on Map") {
                model.showOnMapButtonTapped()
            }
        }
    }
}
