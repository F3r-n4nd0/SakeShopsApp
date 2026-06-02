# ADR 0002: MVVM-C Architecture

## Status
Accepted

## Context & Problem Statement

SakeShops needs a clear, testable architecture for a multi-screen SwiftUI app. SwiftUI provides `NavigationStack` and the `@Observable` macro but offers no out-of-the-box pattern for keeping navigation logic out of views or for injecting dependencies into ViewModels. We needed to decide how to structure Views, state, and navigation so that each layer can be developed and tested in isolation.

## Decision Drivers

* ViewModels must be testable without a running UI
* Views must not import or own navigation logic
* Dependencies (services, clients) must be injectable at a single composition root
* The pattern must remain approachable for a small team without a heavy framework

## Considered Options

* **Option 1: MVVM-C (Model – View – ViewModel – Coordinator)** — Plain `@Observable` ViewModels own feature state; plain `final class` Coordinators wire navigation callbacks and inject dependencies; a single root `AppCoordinator` drives one `NavigationStack`.
* **Option 2: The Composable Architecture (TCA)** — Reducer-based unidirectional state management with built-in navigation and testing tools.
* **Option 3: Plain MVVM** — ViewModels own both state and navigation; views present sheets or push routes directly.

## Decision Outcome

Chosen option: **MVVM-C**, because it cleanly separates navigation from presentation with no third-party dependency, while keeping ViewModels independently testable via simple callback properties.

### Justification

TCA would provide strong correctness guarantees but introduces significant conceptual overhead (reducers, `Store`, `WithViewStore`, effect cancellation) that isn't warranted for a project of this scope. Plain MVVM conflates navigation with feature logic, making ViewModels harder to test in isolation. MVVM-C draws a clean boundary: ViewModels know *what happened* (a row was tapped), Coordinators decide *where to go* (push `.shopDetail`), and `AppCoordinator` owns the single source of truth for the stack.

## Pros and Cons of the Chosen Option

### 🟢 Positive Consequences (Pros)

* ViewModels have no UIKit/SwiftUI import and no `NavigationPath` dependency — straightforward to unit test.
* All navigation decisions live in one place (`AppCoordinator` + feature coordinators), making flows easy to follow.
* New screens slot in by adding an `AppRoute` case and a coordinator — the pattern is mechanical and consistent.
* Zero third-party dependencies for the architectural layer itself.

### 🔴 Negative Consequences (Cons)

* Boilerplate per screen: a coordinator class, a coordinator view, and wired-up callbacks, even for simple screens.
* Deep link handling and complex modal stacks require more manual orchestration than a dedicated navigation framework.
* The `unowned` back-reference from feature coordinators to `AppCoordinator` requires careful lifetime management (handled via `releaseStaleCoordinators()`).

---

## Layer Responsibilities

| Layer | Type | Navigation knowledge |
|---|---|---|
| Model | `struct` / `Decodable` | None |
| ViewModel | `@Observable final class` | None — exposes `onXxx: () -> Void` callbacks |
| View | `SwiftUI.View` | None — calls ViewModel methods only |
| Coordinator | `final class` | Wires `onXxx` → `app.push(_:)` |
| AppCoordinator | `@Observable final class` | Owns `[AppRoute]` path, vends child coordinators |

---

## Navigation Graph

```
AppCoordinatorView
└── NavigationStack(path: $coordinator.path)   // path: [AppRoute]
    │
    ├── [root] HomeCoordinatorView
    │     └── HomeView
    │           ├── "Shop List" button  ──────────────────────────────┐
    │           └── "Map" button  ────────────────────────────────────┤
    │                                                                  │
    ├── [.shopList] ShopListCoordinatorView                           │
    │     └── ShopListView                                            │
    │           └── row tap  ──────────────────────┐                 │
    │                                               │                 │
    ├── [.shopDetail(SakeShop)] ShopDetailCoordinatorView ◄───────────┘
    │     └── ShopDetailView                        │
    │           └── "Show on Map" button  ───────────────────────────┐
    │                                                                  │
    └── [.map(MapLocation)] MapCoordinatorView  ◄─────────────────────┘
          └── MapView  (leaf — no further navigation)
```

```
AppCoordinator  (@Observable, owns NavigationStack path)
│
│  lazy var home: HomeCoordinator
│    └── wires HomeViewModel.onShowShopList  → app.push(.shopList)
│    └── wires HomeViewModel.onShowMap       → app.push(.map(…))
│
│  lazy var shopList: ShopListCoordinator    (released when .shopList leaves path)
│    └── wires ShopListViewModel.onShowDetail → app.push(.shopDetail(shop))
│
│  (ShopDetailCoordinator created fresh per .shopDetail route in AppCoordinatorView)
│    └── wires ShopDetailViewModel.onShowMap  → app.push(.map(…))
│
│  (MapCoordinator created fresh per .map route — leaf, no outbound wiring)
```

### Route ownership

`AppRoute` is the single enum that names every push destination. `AppCoordinatorView` is the only place that switches on it to decide which coordinator/view to create. No feature view or ViewModel ever references `AppRoute` directly.
