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
SakeShopsUITests/        UI tests (XCTest)
SakeShops.xcodeproj/     Xcode project
```

## Building & testing

Open `SakeShops.xcodeproj` in Xcode, select a simulator, and press **⌘R** to run or **⌘U** to run tests.

From the command line:

```bash
# Build
xcodebuild -project SakeShops.xcodeproj -scheme SakeShops \
  -destination 'platform=iOS Simulator,name=iPhone 16' build

# Unit tests
xcodebuild test -project SakeShops.xcodeproj -scheme SakeShops \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:SakeShopsTests

# UI tests
xcodebuild test -project SakeShops.xcodeproj -scheme SakeShops \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:SakeShopsUITests
```
