# ADR 0006: Two-Layer Test Strategy

## Status
Accepted

## Date
2026-06-02

## Deciders
Fernando Luna

## Context & Problem Statement

The MVVM-C architecture separates feature logic (ViewModel) from navigation wiring (Coordinator). Both layers need tests, but combining them in a single test would either force navigation assertions into ViewModel tests or require a full coordinator setup just to verify a business logic outcome. We needed a testing strategy that verifies each layer in isolation without duplication.

## Decision Drivers

* ViewModel tests must not require a real `AppCoordinator` or navigation stack
* Coordinator tests must not re-verify business logic already covered by the ViewModel test
* A failed test must point to exactly one layer, not require tracing through both

## Considered Options

* **Option 1: Two layers — ViewModel tests + Coordinator tests** — ViewModel tests wire an `onXxx` callback to a capture variable, call the method, and assert the capture. Coordinator tests construct the coordinator with a real `AppCoordinator`, call the same method, and assert `app.path`.
* **Option 2: ViewModel tests only** — Assert the callback fires with the right value; trust that coordinators wire it correctly without a test.
* **Option 3: Coordinator tests only** — Assert `app.path` after each action; ViewModel logic is implicitly covered.

## Decision Outcome

Chosen option: **Option 1**, because each layer has a distinct contract that the other layer's tests cannot efficiently verify.

### Justification

Option 2 would leave navigation wiring untested. A coordinator could call `app.push(.shopList)` instead of `app.push(.shopDetail(shop))` and no ViewModel test would catch it. Option 3 conflates navigation correctness with feature logic; a ViewModel bug that fires the wrong callback value would be visible only as a wrong route in `app.path`, making the failure harder to diagnose.

With two layers, the rule is clear: if a callback fires with the wrong *value*, the ViewModel test catches it; if the callback fires but the *route* is wrong, the coordinator test catches it.

## Pros and Cons of the Chosen Option

### 🟢 Positive Consequences

* ViewModel tests are fast and dependency-free — they need only a stub service, not a navigation stack.
* Coordinator tests are narrow — they assert routing only, so a change to ViewModel logic doesn't break them.
* Failures are immediately localised: a ViewModel test failure is a logic bug; a coordinator test failure is a wiring bug.
* The test infrastructure is small: `StubHTTPClient`, `StubShopListService`, and a real `AppCoordinator` cover both layers.

### 🔴 Negative Consequences

* Every navigable action requires two tests (one per layer), increasing test count.
* The discipline must be maintained consciously: it is tempting to assert `app.path` inside a ViewModel test "just to be sure", which defeats the separation.
* `AppCoordinator` is used directly in coordinator tests, so its API is part of the test surface — changes to it can break coordinator tests across all features.

---

## Reference

| Test type | What it constructs | What it asserts |
|---|---|---|
| ViewModel test | ViewModel + stub service + capture closure | Callback fires with correct value |
| Coordinator test | Coordinator + real `AppCoordinator` | `app.path` contains the expected route |
