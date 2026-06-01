import Foundation

enum AppSheet: Identifiable {
    case map(MapLocation)

    var id: String {
        switch self {
        case .map: return "map"
        }
    }
}
