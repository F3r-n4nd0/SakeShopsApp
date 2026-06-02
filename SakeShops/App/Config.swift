import Foundation

enum Config {
    static var baseURL: URL {
        guard
            let string = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String,
            let url = URL(string: string)
        else {
            fatalError("BASE_URL missing or malformed in Info.plist")
        }
        return url
    }
}
