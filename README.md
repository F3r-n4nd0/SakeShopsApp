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

## Architecture

SakeShops follows **MVVM-C** (Model – View – ViewModel – Coordinator). See [ADR-0002](docs/adr/0002-mvvm-c-architecture.md) for the full rationale.

| Layer | Responsibility |
|---|---|
| **Model** | Plain `Decodable`/`Sendable` data types (e.g. `SakeShop`). No UI, no business logic. |
| **ViewModel** | `@Observable final class`. Owns feature state, drives async work, exposes `onXxx` closure properties for navigation events. |
| **View** | SwiftUI `View`. Reads from ViewModel, forwards user gestures to ViewModel methods. Never navigates directly. |
| **Coordinator** | Plain `final class`. Wires ViewModel callbacks to `AppCoordinator.push(_:)` calls. Owns its ViewModel instance. |

`AppCoordinator` is the single navigation root. It holds a `[AppRoute]` path that drives a `NavigationStack` and lazily vends feature coordinators, releasing them when their route leaves the stack.

## Project structure

```
SakeShops/               App source (SwiftUI)
  App/                   Entry point, AppCoordinator, AppRoute, Config
  Core/Networking/       HTTPClient stack (Endpoint, URLSessionHTTPClient, AuthenticatedHTTPClient)
  Features/              One folder per screen (Home, ShopList, ShopDetail, Map)
    <Feature>/
      Coordinator/       XxxCoordinator + XxxCoordinatorView
      ViewModels/        XxxViewModel (@Observable)
      Views/             SwiftUI views
      Models/            Feature-local data types (if any)
      Services/          XxxServiceProtocol + XxxService + XxxEndpoint (if any)
SakeShopsTests/          Unit tests (Swift Testing)
SakeShops.xcodeproj/     Xcode project
docs/adr/                Architecture Decision Records
Configuration/           Per-environment xcconfig files (Debug, Nightly, Release)
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

### Pagination

`ShopsEndpoint` encodes `page` and `pageSize` as `page` / `page_size` query items. `ShopListServiceProtocol` exposes `fetchShops(page: Int, pageSize: Int)`. Callers are responsible for tracking the current page — the service and endpoint are stateless.

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
