import SwiftUI

struct HomeView: View {
    let model: HomeViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HomeMenuItemView(icon: "storefront", title: "Sake Shops", action: model.shopListButtonTapped)
                HomeMenuItemView(icon: "map", title: "Map", action: model.mapButtonTapped)
                HomeMenuItemView(icon: "info.circle", title: "Show Detail", action: model.showDetailButtonTapped)
            }
            .padding()
        }
        .background(Color("MenuBackground"))
        .navigationTitle("SakeShops")
    }
}

#Preview {
    NavigationStack {
        HomeView(model: HomeViewModel())
    }
}
