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
| [ADR-0003](docs/adr/0003-sake-shop-identity.md) | SakeShop identity |
| [ADR-0004](docs/adr/0004-networking-architecture.md) | Networking architecture |
| [ADR-0005](docs/adr/0005-map-as-modal-sheet.md) | Map as modal sheet |
| [ADR-0006](docs/adr/0006-two-layer-test-strategy.md) | Two-layer test strategy |
| [ADR-0007](docs/adr/0007-pagination-strategy.md) | Pagination strategy |

## AI

**Tool used:** [Claude Code](https://claude.ai/code) (Anthropic) — the CLI that runs Claude directly inside the terminal alongside the Xcode project.

**Custom slash command — `/test <Feature>`**

Runs all unit test suites under `SakeShopsTests/Features/<Feature>/` in a single `xcodebuild` invocation, reporting only pass/fail lines. Defined in `.claude/commands/test.md`.

```
/test ShopList   # runs ShopListViewModelTests, ShopListCoordinatorTests, ShopListServiceTests, SakeShopDecodingTests
/test ShopDetail
/test Home
```

**PostToolUse hook — SwiftUI review**

After every `Edit` or `Write` on a file matching `*View.swift` or `*/Views/*.swift`, an agent hook automatically invokes the `swiftui-pro` skill to review the changed view for best practices. Configured in `.claude/settings.local.json`.
