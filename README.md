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

SakeShops follows **MVVM-C** (Model – View – ViewModel – Coordinator). ViewModels own feature state and expose event callbacks; Coordinators wire those callbacks to navigation actions. A single root coordinator owns the navigation stack. See [ADR-0002](docs/adr/0002-mvvm-c-architecture.md) for the full rationale.

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

The networking layer lives in `Core/Networking/` and is protocol-based, using Swift async/await. Any request is a type conforming to `Endpoint`; callers depend on `HTTPClient` and never on the concrete implementation. Feature services map `NetworkError` to a feature-specific error type before exposing results to ViewModels.

To add a new endpoint:

1. Create a type conforming to `Endpoint` with the required `path` and `method`.
2. Define a feature-level service protocol and a concrete service that calls `send(…)` and maps errors.
3. Inject `any YourServiceProtocol` into the ViewModel — never the concrete type.

## Prerequisites

- Xcode 16 or later
- macOS Sequoia or later

No additional setup is required. The `Configuration/Debug.xcconfig` file is committed and points to the Beeceptor mock API, so the Debug build works out of the box. Nightly and Release builds use separate `BASE_URL` values defined in their respective xcconfig files.

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
