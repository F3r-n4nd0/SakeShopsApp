# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

SakeShops is an iOS/iPadOS SwiftUI app targeting iOS 18.0+, written in Swift. The project is at the initial scaffold stage — only the Xcode template boilerplate exists so far.

- Bundle ID: `fluna.personal.SakeShops`
- Supported devices: iPhone + iPad (`TARGETED_DEVICE_FAMILY = "1,2"`)

## Build & Test

Build from the command line (requires Xcode installed):

```bash
# Build for simulator
xcodebuild -project SakeShops.xcodeproj -scheme SakeShops -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run unit tests (Swift Testing)
xcodebuild test -project SakeShops.xcodeproj -scheme SakeShops -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:SakeShopsTests

# Run UI tests
xcodebuild test -project SakeShops.xcodeproj -scheme SakeShops -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:SakeShopsUITests

# Run a single test by name
xcodebuild test -project SakeShops.xcodeproj -scheme SakeShops -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:SakeShopsTests/SakeShopsTests/example
```

## Code Structure

- `SakeShops/` — app source (entry point `SakeShopsApp.swift`, views starting with `ContentView.swift`)
- `SakeShopsTests/` — unit tests using Swift Testing (`import Testing`, `@Test` functions, `#expect`)
- `SakeShopsUITests/` — UI tests using XCTest

## Testing Conventions

Unit tests use the **Swift Testing** framework (not XCTest): use `@Test`, `#expect(...)`, and `#require(...)`. UI tests continue to use XCTest.
