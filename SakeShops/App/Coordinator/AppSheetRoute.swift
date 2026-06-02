// docs/adr/0005-map-as-modal-sheet.md
enum AppSheetRoute: Identifiable, Hashable {
    case map(MapLocation)

    var id: String {
        switch self {
        case .map(let location): return "map-\(location.latitude)-\(location.longitude)"
        }
    }
}
