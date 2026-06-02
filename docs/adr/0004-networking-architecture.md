# ADR 0004: Networking Architecture

## Status
Accepted

## Date
2026-06-02

## Deciders
Fernando Luna

## Context & Problem Statement

The app needs an HTTP layer that can send authenticated requests, decode responses, and map failures into typed errors — without coupling feature code to `URLSession` directly. We also needed auth injection to be optional so unauthenticated endpoints don't carry unnecessary token logic, and so the entire stack can be swapped out in tests.

## Decision Drivers

* Feature services must depend on an abstraction, not a concrete transport
* Auth token injection must be opt-in at composition time, not baked into every request
* The networking stack must be testable without network access
* Typed, inspectable errors are required for mapping to feature-level error types

## Considered Options

* **Option 1: Protocol-based `HTTPClient` + decorator for auth** — A single `send<T>(_:)` protocol backed by `URLSessionHTTPClient`; an `AuthenticatedHTTPClient` decorator wraps any `HTTPClient` and injects a `Bearer` token before forwarding.
* **Option 2: Alamofire** — Third-party library with built-in auth interceptors, retry, and request adapters.
* **Option 3: `URLSession` directly in each service** — Each feature service owns a `URLSession` and constructs its own `URLRequest`.

## Decision Outcome

Chosen option: **Option 1**, because it achieves auth composability and testability with no external dependencies and minimal surface area.

### Justification

Alamofire would solve the same problems but introduces a third-party dependency for functionality that is straightforward to implement from first principles at this scope. Option 3 scatters networking logic across services, makes auth injection repetitive, and ties services directly to `URLSession`, making them hard to test without `MockURLProtocol`.

The decorator approach keeps each type small and focused. `URLSessionHTTPClient` handles transport; `AuthenticatedHTTPClient` handles token injection; feature services never see either concrete type.

## Pros and Cons of the Chosen Option

### 🟢 Positive Consequences

* `StubHTTPClient` can be used in feature-service tests without network access or `URLProtocol` interception.
* Auth can be added or removed at the composition root without touching services or endpoints.
* `Endpoint` conformance is the only contract a new request type must satisfy; defaults on the extension make simple GET endpoints trivially short.
* `NetworkError` carries raw `Data` and `DecodingError` so callers can inspect or re-map failures without losing information.

### 🔴 Negative Consequences

* No built-in retry, request queuing, or certificate pinning — each would need to be added as a new decorator or handled in `URLSessionHTTPClient`.
* `AuthorizedEndpoint` is a private wrapper inside `AuthenticatedHTTPClient`; extending auth behaviour (e.g., refresh on 401) requires modifying that type.
* `NetworkError.statusCode(Int, Data)` and `.decoding(DecodingError)` are richer than a simple message string, so callers must map them before displaying to users.

---

## Stack Layout

```
Feature service
      │ depends on
      ▼
any HTTPClient  ◄──────────────────────────────────────────┐
      ▲                                                     │
      │ wraps                                               │
AuthenticatedHTTPClient (injects Bearer token)             │
      │ wraps                                               │
URLSessionHTTPClient (sends URLRequest, decodes response) ─┘
```

`TokenProvider` is injected into `AuthenticatedHTTPClient`; swap in a stub at the composition root to produce arbitrary tokens in tests.
