# SakeShops

An iOS/iPadOS app for discovering sake shops.

## Requirements

- Xcode 16+
- macOS Sequoia+
- iOS 18.0+ deployment target ([ADR-0001](docs/adr/0001-minimum-ios-version-selection.md))

## Getting started

No additional setup required. Open `SakeShops.xcodeproj`, select a simulator, and press **⌘R** to run or **⌘U** to test. The Debug build points to a Beeceptor mock API out of the box.

## Project structure

```
SakeShops/          App source
  App/              Entry point, root coordinator, navigation routes, config
  Core/Networking/  HTTP client stack
  Features/         One folder per screen (Home, ShopList, ShopDetail, Map)
SakeShopsTests/     Unit tests
Configuration/      Per-environment xcconfig files (Debug, Nightly, Release)
docs/adr/           Architecture Decision Records
```

## Architecture

MVVM-C — ViewModels own feature state, Coordinators handle navigation. See [ADR-0002](docs/adr/0002-mvvm-c-architecture.md).

## Architecture Decision Records

| # | Decision |
|---|---|
| [ADR-0001](docs/adr/0001-minimum-ios-version-selection.md) | Minimum iOS version selection |
| [ADR-0002](docs/adr/0002-mvvm-c-architecture.md) | MVVM-C architecture |
