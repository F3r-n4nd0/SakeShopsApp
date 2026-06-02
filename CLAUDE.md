# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

SakeShops is an iOS/iPadOS SwiftUI app for discovering sake shops, targeting iOS 18.0+.

- Bundle ID: `fluna.personal.SakeShops`
- Supported devices: iPhone + iPad (`TARGETED_DEVICE_FAMILY = "1,2"`)
- Architectural decisions are recorded in `docs/adr/`.

## README

Keep `README.md` brief. It should only contain what a new contributor needs to get started: requirements, how to run the app, and a high-level project structure overview. Do not explain implementation details inline — link to the relevant ADR in `docs/adr/` instead. If a section is growing, move the detail into a new ADR and replace it with a link.

## CI

The workflow at `.github/workflows/build.yml` runs on every push to `main` (i.e. after a merge). It builds on `macos-15` using an `iPhone 16` simulator with code signing disabled (`CODE_SIGN_IDENTITY=""`, `CODE_SIGNING_REQUIRED=NO`, `CODE_SIGNING_ALLOWED=NO`) — no certificates are available in the runner environment. The build status badge in `README.md` reflects the latest run.

When writing CI-related changes: keep the simulator name in the workflow in sync with what `macos-15` runners actually ship (currently iPhone 16). Do not use `iPhone 17` in the workflow — that simulator is not available on GitHub-hosted runners.

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

### Navigation (Coordinator pattern)

Navigation is driven by a single `NavigationStack` owned by `AppCoordinatorView`, with `AppCoordinator` (@Observable) managing the path as `[AppRoute]`.

- **`AppRoute`** — `enum` of all push destinations (`.shopList`, `.shopDetail(SakeShop)`, `.map(MapLocation)`). All `navigationDestination` switching lives in `AppCoordinatorView`.
- **`AppCoordinator`** — owns the path and lazily vends child coordinators (`home`, `shopList`). Calls `releaseStaleCoordinators()` on every `path` change to nil out coordinators whose route is no longer in the stack.
- **Feature coordinators** (`HomeCoordinator`, `ShopListCoordinator`, `ShopDetailCoordinator`, `MapCoordinator`) — plain `final class`, not `@Observable`. Each holds an `unowned` back-reference to `AppCoordinator` and creates its ViewModel at init, wiring up the VM's `onXxx` callbacks to `app.push(_:)` calls.
- **CoordinatorViews** — thin `View` structs that hold a coordinator as `@State` (when constructing it, e.g. `ShopDetailCoordinatorView`) or as a `let` (when receiving it, e.g. `ShopListCoordinatorView`), then pass the coordinator's `viewModel` into the feature `View`.

To add a new navigation destination: add a case to `AppRoute`, add a `navigationDestination` branch in `AppCoordinatorView`, create a `XxxCoordinator` + `XxxCoordinatorView`, and add a lazy accessor on `AppCoordinator` if the coordinator needs to survive across multiple views.

**Coordinator back-references** — Feature coordinators hold `private unowned let app: AppCoordinator`, never `weak`. The coordinator's lifetime is bounded by `AppCoordinator` owning it, so `unowned` is safe. Leaf coordinators with no outbound navigation (e.g. `MapCoordinator`) need no back-reference at all.

**`@State` vs `let` in CoordinatorViews** — Use `@State` when the CoordinatorView constructs the coordinator itself (ephemeral destinations instantiated inside `navigationDestination`, e.g. `ShopDetailCoordinatorView`, `MapCoordinatorView`). Use `let` when `AppCoordinator` owns the coordinator's lifetime and passes it in (persistent coordinators, e.g. `HomeCoordinatorView`, `ShopListCoordinatorView`).

### ViewModels

ViewModels are `@Observable @MainActor final class`. Navigation actions are expressed as callback properties (`var onShowDetail: (SakeShop) -> Void = { _ in }`) that coordinators overwrite at init. Views only call named ViewModel methods (e.g. `shopRowTapped(_:)`, `showOnMapButtonTapped()`); they never call `onXxx` closures directly. Because ViewModels are `@MainActor`, test suites that instantiate them must also be annotated `@MainActor`.

Views receive their ViewModel as a plain `let model:` stored property — never `@Bindable` or `@EnvironmentObject`. `@Observable` is sufficient for SwiftUI to track changes.

### Networking layer (`Core/Networking/`)

Protocol-based, async/await. The central abstraction is `HTTPClient: Sendable` with a single generic `send<T: Decodable>(_ endpoint: some Endpoint) async throws -> T` method.

- **`Endpoint`** protocol — any request is a type conforming to `Endpoint` (path, method, headers, queryItems, body). Default implementations provided for all optional fields.
- **`URLSessionHTTPClient`** — real implementation; takes a `baseURL` + optional `URLSession` and `JSONDecoder` at init.
- **`AuthenticatedHTTPClient`** — decorator that wraps any `HTTPClient` and injects a `Bearer` token header before forwarding the call. Takes a `base: any HTTPClient` and a `tokenProvider: any TokenProvider`. Token injection is done via a private `AuthorizedEndpoint` wrapper, so the wrapped endpoint's existing headers are preserved.
- **`TokenProvider`** — protocol (`func token() async throws -> String`) for supplying auth tokens; inject a concrete implementation at the composition root.
- **`NetworkError`** — maps HTTP/decoding/connection failures into typed cases: `.invalidURL`, `.invalidResponse`, `.statusCode(Int, Data)`, `.decoding(DecodingError)`, `.underlying(any Error)`.

### Feature services

Each feature defines its own error enum and service protocol. Example flow for `ShopList`:

1. `ShopsEndpoint: Endpoint` — defines path `/shops`, method `.get`, and encodes `page` + `pageSize` as `page` / `page_size` query items.
2. `ShopListServiceProtocol` — `func fetchShops(page: Int, pageSize: Int) async throws -> [SakeShop]`
3. `ShopListService` — conforms to the protocol; calls `client.send(ShopsEndpoint(page:pageSize:))` and maps `NetworkError` → `ShopListError` (`.fetchFailed` / `.decodingFailed`). Callers own cursor state.

Callers depend on `any ShopListServiceProtocol`, never the concrete type.

### Model (`SakeShop`)

`SakeShop` is `Decodable`, `Identifiable` (via `name` as `id`), `Sendable`. Notable: `coordinates` decodes from a JSON `[lat, lng]` array using a custom `init(from:)` with an unkeyed container — this is not standard keyed decoding.

### Configuration

`BASE_URL` is defined per build configuration in `Configuration/*.xcconfig` and read at runtime via `Config.baseURL` from `Info.plist`. Three configurations exist: Debug → Beeceptor mock, Nightly → `nightly-api.sakeshops.com`, Release → production API. Never hardcode base URLs in source — add a new xcconfig entry and read it through `Config`.

## Testing conventions

Unit tests use **Swift Testing**: `import Testing`, `@Suite`, `@Test`, `#expect`, `#require`.

Test names follow `methodName_condition_expectedOutcome` (e.g. `task_setsShops_onSuccess`, `push_appendsRouteToPath`).

**Two-layer test strategy:**
- *ViewModel tests* — wire an `onXxx` callback to a capture variable, call the ViewModel method, assert the capture. These tests verify that the right callback fires with the right value; they know nothing about navigation.
- *Coordinator tests* — construct the coordinator with a real `AppCoordinator`, call a ViewModel method, assert `app.path`. These tests verify the navigation wiring only. Never assert navigation routing inside a ViewModel test.

### Test infrastructure (`SakeShopsTests/Helpers/`)

- **`StubHTTPClient`** (`@unchecked Sendable`) — set `stub.result: Result<Data, NetworkError>` before calling; decodes the data just like the real client.
- **`MockURLProtocol`** — intercepts `URLSession` requests; set `MockURLProtocol.requestHandler` per test.
- **`makeURLSessionClient(baseURL:)`** — factory that returns a `URLSessionHTTPClient` backed by `MockURLProtocol`; use this instead of constructing it manually in `URLSessionHTTPClient` tests.
- **`makeHTTPResponse(url:statusCode:)`** — factory for building `HTTPURLResponse` values in tests.
- **`makeSakeShopsData(count:)`** — loads `SakeShopsTests/Resources/shops.json` from the test bundle and returns the first `count` entries re-encoded as `Data`.
- **`StubShopListService`** — lives at `SakeShopsTests/Features/ShopList/Services/`; set `stub.result: Result<[SakeShop], ShopListError>`. Used in coordinator tests where a fixed result is sufficient.

For ViewModel tests that need to mutate the result mid-test (e.g. to simulate pagination), define a private `final class` conforming to the service protocol locally in the test file rather than extending `StubShopListService`.

**Stubs live only in the test target**, never in the app target.

`URLSessionHTTPClientTests` is `@Suite(.serialized)` because `MockURLProtocol.requestHandler` is static shared state.
