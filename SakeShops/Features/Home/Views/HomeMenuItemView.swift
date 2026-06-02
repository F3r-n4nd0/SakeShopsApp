import SwiftUI

struct HomeMenuItemView: View {
    let icon: String
    let title: String
    let action: () -> Void

    @ScaledMetric private var iconSize: CGFloat = 50

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: iconSize, height: iconSize)
                    .background(.tint, in: RoundedRectangle(cornerRadius: 12))

                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.background, in: RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

#Preview {
    HomeMenuItemView(icon: "storefront", title: "Sake Shops", action: { })
}
