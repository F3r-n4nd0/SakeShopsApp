import SwiftUI

struct StarRatingView: View {
    let rating: Double
    private let maxStars = 5

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxStars, id: \.self) { index in
                starImage(for: index)
                    .foregroundStyle(.yellow)
            }
            Text(String(format: "%.1f", rating))
                .foregroundStyle(.secondary)
                .font(.subheadline)
        }
    }

    private func starImage(for index: Int) -> Image {
        let threshold = Double(index)
        if rating >= threshold {
            return Image(systemName: "star.fill")
        } else if rating >= threshold - 0.5 {
            return Image(systemName: "star.leadinghalf.filled")
        } else {
            return Image(systemName: "star")
        }
    }
}

#Preview {
    VStack(spacing: 8) {
        StarRatingView(rating: 4.5)
        StarRatingView(rating: 3.0)
        StarRatingView(rating: 1.7)
    }
    .padding()
}
