# ADR 0003: SakeShop Identity

## Status
Accepted

## Date
2026-06-02

## Deciders
Fernando Luna

## Context & Problem Statement
`SakeShop` must conform to `Identifiable` for use in SwiftUI `ForEach` and `List`. The current API response does not include a stable `id` field, so a surrogate must be chosen until the API is updated.

## Decision Drivers
* No stable identifier is provided by the API today
* SwiftUI diffing and list animations depend on identity stability
* Two shops with the same name would produce a collision

## Considered Options
* **Option 1: `name` as `id`** — Use the shop name as the identifier. Simple; requires no API change.
* **Option 2: Client-generated UUID** — Assign a `UUID` on decode. Stable within a session but changes across network fetches, breaking SwiftUI diffing on refresh.
* **Option 3: Wait for API `id` field** — Block `Identifiable` conformance until the backend provides a stable identifier.

## Decision Outcome
Chosen option: **Option 1 (`name` as `id`)**, because it is the least disruptive stopgap while the API is updated to include a proper identifier.

### Justification
The app's shop data is read-only and shop names are unique in the current dataset. The collision risk is acceptable for the initial release. Option 2 would cause worse diffing behaviour than Option 1 on list refreshes.

## Pros and Cons of the Chosen Option

### 🟢 Positive Consequences
* No API change required to ship
* Straightforward conformance; no extra fields to manage

### 🔴 Negative Consequences
* Two shops with the same name produce a SwiftUI identity collision
* Renaming a shop across pages causes the old and new rows to be treated as different items
* Must be replaced with a server-provided `id` field once the API supports it
