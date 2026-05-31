# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

SakeShops is an iOS/iPadOS SwiftUI app for discovering sake shops, targeting iOS 18.0+.

- Bundle ID: `fluna.personal.SakeShops`
- Supported devices: iPhone + iPad (`TARGETED_DEVICE_FAMILY = "1,2"`)

## Build & Test

```bash
# Build
xcodebuild -project SakeShops.xcodeproj -scheme SakeShops \
  -destination 'platform=iOS Simulator,name=iPhone 17' build

# Run all unit tests
xcodebuild test -project SakeShops.xcodeproj -scheme SakeShops \
  -destination 'platform=iOS Simulator,name=iPhone 17' -only-testing:SakeShopsTests

# Run a single test suite
xcodebuild test -project SakeShops.xcodeproj -scheme SakeShops \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:SakeShopsTests/ShopListServiceTests

# Run a single test
xcodebuild test -project SakeShops.xcodeproj -scheme SakeShops \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -only-testing:SakeShopsTests/ShopListServiceTests/fetchShops_returnsShops_onSuccess
```

## Architecture

### Networking layer (`Core/Networking/`)

Protocol-based, async/await. The central abstraction is `HTTPClient: Sendable` with a single generic `send<T: Decodable>(_ endpoint: some Endpoint) async throws -> T` method.

- **`Endpoint`** protocol — any request is a type conforming to `Endpoint` (path, method, headers, queryItems, body). Default implementations provided for all optional fields.
- **`URLSessionHTTPClient`** — real implementation; takes a `baseURL` + optional `URLSession` and `JSONDecoder` at init.
- **`NetworkError`** — maps HTTP/decoding/connection failures into typed cases: `.statusCode(Int, Data)`, `.decoding(DecodingError)`, `.underlying(any Error)`.

### Feature services

Each feature defines its own error enum and service protocol. Example flow for `ShopList`:

1. `ShopsEndpoint: Endpoint` — defines path `/shops`, method `.get`, and encodes `page` + `pageSize` as `page` / `page_size` query items.
2. `ShopListServiceProtocol` — `func fetchShops(page: Int, pageSize: Int) async throws -> [SakeShop]`
3. `ShopListService` — conforms to the protocol; calls `client.send(ShopsEndpoint(page:pageSize:))` and maps `NetworkError` → `ShopListError` (`.fetchFailed` / `.decodingFailed`). Callers own cursor state.

Callers depend on `any ShopListServiceProtocol`, never the concrete type.

### Model (`SakeShop`)

`SakeShop` is `Decodable`, `Identifiable` (via `name`), `Sendable`. Notable: `coordinates` decodes from a JSON `[lat, lng]` array using a custom `init(from:)` with an unkeyed container — this is not standard keyed decoding.

## Testing conventions

Unit tests use **Swift Testing**: `import Testing`, `@Suite`, `@Test`, `#expect`, `#require`.

### Test infrastructure (`SakeShopsTests/Helpers/`)

- **`StubHTTPClient`** (`@unchecked Sendable`) — set `stub.result: Result<Data, NetworkError>` before calling; decodes the data just like the real client.
- **`StubShopListService`** — set `stub.result: Result<[SakeShop], ShopListError>`.
- **`MockURLProtocol`** — intercepts `URLSession` requests; set `MockURLProtocol.requestHandler` per test.
- **`makeSakeShopsData(count:)`** — loads `SakeShopsTests/Resources/shops.json` from the test bundle and returns the first `count` entries re-encoded as `Data`.

**Stubs live only in the test target**, never in the app target.

`URLSessionHTTPClientTests` is `@Suite(.serialized)` because `MockURLProtocol.requestHandler` is static shared state.
