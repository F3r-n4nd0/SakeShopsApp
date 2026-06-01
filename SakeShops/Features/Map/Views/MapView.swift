import SwiftUI
import MapKit

struct MapView: View {
    let location: MapLocation

    var body: some View {
        Map(initialPosition: .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            ),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        ))) {
            Annotation(location.label, coordinate: CLLocationCoordinate2D(
                latitude: location.latitude,
                longitude: location.longitude
            )) {
                Image(systemName: "mappin.circle.fill")
                    .foregroundStyle(.red)
            }
        }
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
    }
}
