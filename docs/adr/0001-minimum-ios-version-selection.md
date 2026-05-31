# ADR 0001: Minimum iOS Version Selection

## Status
Accepted

## The Problem
We need to choose the lowest iOS version our demo project will support. Since this is a demo, we want to avoid complex SwiftUI fallback hacks while still supporting an older, non-current OS version for realistic testing.

## The Choice: iOS 18.0
We are setting our minimum requirement to **iOS 18.0**.

## Why We Chose It
1. **Demo Simplification**: It eliminates the need for messy conditional code overrides and legacy compatibility layers.
2. **Modern Testing**: It allows us to use the new **Swift Testing** framework right out of the box.
3. **Stable SwiftUI**: It avoids known layout bugs and data syncing crashes present in earlier SwiftUI versions.

## What We Rejected
* **Latest iOS Version**: Rejected because we want to demonstrate support for an older, non-current operating system.
* **iOS 17 and Older**: Rejected because early framework bugs would complicate the demo development process.

## Trade-offs

### 🟢 The Good
* Clean code with zero outdated fallback hacks.
* Stable data storage layers and great testing tools.
* Perfect balance for a streamlined demonstration.

### 🔴 The Bad
* Does not showcase backward compatibility strategies for legacy devices.
* Cannot use design styles exclusive to the absolute newest operating systems.
