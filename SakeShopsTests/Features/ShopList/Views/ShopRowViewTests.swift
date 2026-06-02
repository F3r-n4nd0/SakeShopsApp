import SnapshotTesting
import SwiftUI
import Testing
@testable import SakeShops

@Suite("ShopRowView")
@MainActor
struct ShopRowViewTests {

    @Test func appearance_light() {
        assertSnapshot(
            of: ShopRowView(shop: makeSakeShop(name: "信州スシサカバ 寿しなの", rating: 4.5))
                .environment(\.colorScheme, .light),
            as: .image(layout: .sizeThatFits)
        )
    }

    @Test func appearance_dark() {
        assertSnapshot(
            of: ShopRowView(shop: makeSakeShop(name: "信州スシサカバ 寿しなの", rating: 4.5))
                .environment(\.colorScheme, .dark),
            as: .image(layout: .sizeThatFits)
        )
    }

    @Test func rating_fullStars() {
        assertSnapshot(
            of: ShopRowView(shop: makeSakeShop(rating: 5.0)),
            as: .image(layout: .sizeThatFits)
        )
    }

    @Test func rating_halfStar() {
        assertSnapshot(
            of: ShopRowView(shop: makeSakeShop(rating: 3.5)),
            as: .image(layout: .sizeThatFits)
        )
    }

    @Test func rating_lowRating() {
        assertSnapshot(
            of: ShopRowView(shop: makeSakeShop(rating: 1.0)),
            as: .image(layout: .sizeThatFits)
        )
    }
}
