# ADR 0001: Minimum iOS Version Selection

## Status
Accepted

## Date
2026-05-31

## Deciders
Fernando Luna

## Context & Problem Statement

We need to choose the lowest iOS version SakeShops will support. The target is a balance between using modern SwiftUI and Swift Testing without workarounds, while still not requiring the absolute latest OS release.

## Decision Drivers

* Avoid conditional code and legacy compatibility layers that complicate a demo project
* Use Swift Testing out of the box without availability guards
* Build on a stable SwiftUI release free of known layout and data-sync bugs

## Considered Options

* **iOS 18.0** — one major version behind the current release at decision time; stable SwiftUI, full Swift Testing support, no fallback hacks required.
* **Latest iOS version** — would restrict the app to devices on the very newest OS, reducing the realism of the demo.
* **iOS 17 or older** — would require workarounds for SwiftUI bugs and unavailable framework APIs.

## Decision Outcome

Chosen option: **iOS 18.0**, because it is the oldest version that supports Swift Testing natively and avoids the known SwiftUI instability present in earlier releases, while still representing a non-current OS for demonstration purposes.

### Justification

The latest iOS version was rejected because the project should demonstrate support for a non-current OS, not just the newest one. iOS 17 and older were rejected because early SwiftUI versions have known layout and data-sync issues that would complicate development, and Swift Testing is not available without workarounds on those targets. iOS 18.0 hits the right balance: clean APIs, stable framework behaviour, and no availability guards needed.

## Pros and Cons of the Chosen Option

### 🟢 Positive Consequences

* No conditional code or legacy compatibility layers.
* Swift Testing and `@Observable` available without restrictions.
* Stable SwiftUI layout and data storage behaviour.

### 🔴 Negative Consequences

* Does not demonstrate backward compatibility strategies for older devices.
* Cannot use APIs exclusive to the very latest OS releases.
