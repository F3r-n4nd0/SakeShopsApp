protocol TokenProvider: Sendable {
    func token() async throws -> String
}
