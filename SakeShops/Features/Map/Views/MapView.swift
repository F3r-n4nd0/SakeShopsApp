import SwiftUI
import MapKit

struct MapView: View {
    let model: MapViewModel

    var body: some View {
        Map(initialPosition: .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: model.location.latitude,
                longitude: model.location.longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))) {
            Annotation(model.location.label, coordinate: CLLocationCoordinate2D(
                latitude: model.location.latitude,
                longitude: model.location.longitude
            )) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundStyle(.red)
            }
        }
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
    }
}
