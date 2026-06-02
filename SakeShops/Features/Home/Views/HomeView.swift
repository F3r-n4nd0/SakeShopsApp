import SwiftUI

struct HomeView: View {
    let model: HomeViewModel

    var body: some View {
        List {
            Button("Sake Shops") {
                model.shopListButtonTapped()
            }
            Button("Map") {
                model.mapButtonTapped()
            }
        }
        .navigationTitle("Home")
    }
}

#Preview {
    HomeView(model: HomeViewModel())
}
