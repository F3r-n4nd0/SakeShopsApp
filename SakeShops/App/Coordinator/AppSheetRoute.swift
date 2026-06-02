enum AppSheetRoute: Identifiable, Hashable {
    case map(MapLocation)

    var id: String {
        switch self {
        case .map(let location): return "map-\(location.latitude)-\(location.longitude)"
        }
    }
}
