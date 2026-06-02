import SwiftUI

struct ShopRowView: View {
    let shop: SakeShop

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(shop.name)
                .font(.headline)
            Text(shop.address)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            StarRatingView(rating: shop.rating)
        }
        .padding(.vertical, 4)
    }
}
