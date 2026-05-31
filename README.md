# SakeShops

An iOS/iPadOS app for discovering sake shops.

## Configuration

| Setting | Value |
|---|---|
| Platform | iOS / iPadOS |
| Deployment target | iOS 18.0 ([ADR-0001](docs/adr/0001-minimum-ios-version-selection.md)) |
| Devices | iPhone + iPad |
| Swift version | 5.0 |
| Bundle identifier | `fluna.personal.SakeShops` |

## Project structure

```
SakeShops/               App source (SwiftUI)
SakeShopsTests/          Unit tests (Swift Testing)
SakeShops.xcodeproj/     Xcode project
```

## Networking

The networking layer lives in `SakeShops/Core/Networking/` and is protocol-based, using Swift async/await throughout.

### Key types

| Type | Role |
|---|---|
| `Endpoint` | Protocol — any request conforms to it, declaring `path`, `method`, optional `headers`, `queryItems`, and `body`. Defaults are provided for all optional fields. |
| `HTTPClient` | Protocol — single generic method `send<T: Decodable>(_ endpoint: some Endpoint) async throws -> T`. Callers depend only on this protocol. |
| `URLSessionHTTPClient` | Concrete implementation. Takes a `baseURL`, an optional `URLSession`, and an optional `JSONDecoder` at init. Builds the `URLRequest`, executes it, validates the HTTP status, and decodes the response. |
| `NetworkError` | Typed error enum: `.invalidURL`, `.invalidResponse`, `.statusCode(Int, Data)`, `.decoding(DecodingError)`, `.underlying(any Error)`. |

### Adding a new endpoint

1. Create a type that conforms to `Endpoint` and set `path` and `method`. Override `queryItems`, `headers`, or `body` only when needed.
2. Define a feature-level service protocol and a concrete service that accepts `any HTTPClient`, calls `send(…)`, and maps `NetworkError` to a feature-specific error type.
3. Callers inject `any YourServiceProtocol` — never the concrete type.

### Testing

`URLSessionHTTPClient` is tested via `MockURLProtocol`, which intercepts `URLSession` requests without hitting the network. Feature services are tested via `StubHTTPClient`. Both helpers live in the test target only.

## Building & testing

Open `SakeShops.xcodeproj` in Xcode, select a simulator, and press **⌘R** to run or **⌘U** to run tests.

From the command line:

```bash
# Build
xcodebuild -project SakeShops.xcodeproj -scheme SakeShops \
  -destination 'platform=iOS Simulator,name=iPhone 17' build

# Unit tests
xcodebuild test -project SakeShops.xcodeproj -scheme SakeShops \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:SakeShopsTests
```
