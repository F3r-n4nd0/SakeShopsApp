# ADR 0005: Map as Modal Sheet

## Status
Accepted

## Date
2026-06-02

## Deciders
Fernando Luna

## Context & Problem Statement

The map screen is reached from `ShopDetailView` via a "Show on Map" button. We needed to decide how to present it: pushed onto the `NavigationStack` like all other destinations, or presented modally as a sheet. This choice also determines whether map belongs in `AppRoute` alongside `.shopList` and `.shopDetail`, or in a separate enum.

## Decision Drivers

* The map is a glanceable overlay — users open it to check a location and dismiss it, not to navigate deeper from it
* A modal presentation makes the dismissal gesture (swipe down) immediately obvious to users
* `NavigationStack` push destinations and modal presentations carry different UX semantics that should be reflected in the model

## Considered Options

* **Option 1: Modal sheet with a separate `AppSheetRoute` enum** — Map is presented via `.sheet(item:)` driven by `AppCoordinator.sheetRoute: AppSheetRoute?`. A second enum `AppSheetRoute` exists alongside `AppRoute` for all sheet destinations.
* **Option 2: Push onto `NavigationStack` via `AppRoute`** — Map is a case in `AppRoute`, presented with a back button like ShopList and ShopDetail.
* **Option 3: `fullScreenCover`** — Map fills the entire screen without the visible card drag handle, using the same `AppSheetRoute` mechanism.

## Decision Outcome

Chosen option: **Option 1**, because a map that the user opens briefly to check a location is conceptually an overlay, not a navigation step, and the sheet presentation communicates that intent through its visual affordances.

### Justification

Pushing the map onto the stack (Option 2) would give it a back button and place it at the same navigational depth as ShopDetail, which misrepresents its role. Users would need to tap Back rather than swipe down to dismiss, and deep-linking or stack restoration would need to handle it as a true navigation destination.

`fullScreenCover` (Option 3) would remove the sheet drag handle and feel heavier than the task warrants.

A separate `AppSheetRoute` enum makes the push/modal distinction explicit at the type level: anything in `AppRoute` is a push destination; anything in `AppSheetRoute` is a modal.

## Pros and Cons of the Chosen Option

### 🟢 Positive Consequences

* Swipe-to-dismiss works out of the box; no custom dismissal logic needed in `MapViewModel`.
* `AppRoute` stays clean — it only contains destinations that belong on the navigation stack.
* Adding future sheet destinations (e.g., filters, share sheets) follows the same `AppSheetRoute` case pattern.

### 🔴 Negative Consequences

* Two route enums (`AppRoute` and `AppSheetRoute`) must be kept in sync with `AppCoordinatorView` — a new sheet destination requires touching both.
* `AppSheetRoute.id` is computed from coordinates rather than a stable identifier, because `MapLocation` carries no server-provided ID. This is a stopgap: two distinct locations with identical floating-point coordinates would produce the same sheet identity (in practice impossible with real GPS data).
* Sheet state lives on `AppCoordinator` as `var sheetRoute: AppSheetRoute?`, which means only one sheet can be open at a time.
