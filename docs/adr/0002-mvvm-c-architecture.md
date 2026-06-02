# ADR 0002: MVVM-C Architecture

## Status
Accepted

## Date
2026-06-01

## Deciders
Fernando Luna

## Context & Problem Statement

SakeShops needs a clear, testable architecture for a multi-screen SwiftUI app. SwiftUI provides `NavigationStack` and the `@Observable` macro but offers no out-of-the-box pattern for keeping navigation logic out of views or for injecting dependencies into ViewModels. We needed to decide how to structure Views, state, and navigation so that each layer can be developed and tested in isolation.

## Decision Drivers

* ViewModels must be testable without a running UI
* Views must not import or own navigation logic
* Dependencies (services, clients) must be injectable at a single composition root
* The pattern must remain approachable for a small team without a heavy framework

## Considered Options

* **Option 1: MVVM-C (Model – View – ViewModel – Coordinator)** — ViewModels own feature state and expose event callbacks; Coordinators wire those callbacks to navigation actions and inject dependencies; a single root coordinator owns the navigation stack.
* **Option 2: The Composable Architecture (TCA)** — Reducer-based unidirectional state management with built-in navigation and testing tools.
* **Option 3: Plain MVVM** — ViewModels own both feature state and navigation; views trigger navigation directly.

## Decision Outcome

Chosen option: **MVVM-C**, because it cleanly separates navigation from presentation with no third-party dependency, while keeping ViewModels independently testable via simple callback properties.

### Justification

TCA would provide strong correctness guarantees but introduces significant conceptual overhead that isn't warranted for a project of this scope. Plain MVVM conflates navigation with feature logic, making ViewModels harder to test in isolation. MVVM-C draws a clean boundary: ViewModels know *what happened*, Coordinators decide *where to go*, and the root coordinator owns the single source of truth for the navigation stack.

## Pros and Cons of the Chosen Option

### 🟢 Positive Consequences

* ViewModels have no UI or navigation framework dependency — straightforward to unit test in isolation.
* All navigation decisions live in coordinators, making flows easy to follow and change without touching views.
* New screens slot in by adding a route case and a coordinator — the pattern is mechanical and consistent.
* Zero third-party dependencies for the architectural layer itself.

### 🔴 Negative Consequences

* Boilerplate per screen: a coordinator, a coordinator view, and wired-up callbacks, even for simple destinations.
* Deep link handling and complex modal stacks require more manual orchestration than a dedicated navigation framework.
* Feature coordinators hold a back-reference to the root coordinator, which requires attention to object lifetime.

---

## Layer Responsibilities

| Layer | Responsibility | Navigation knowledge |
|---|---|---|
| Model | Data representation | None |
| ViewModel | Feature state and user intent | None — exposes event callbacks for navigation triggers |
| View | Render state, forward user actions to ViewModel | None |
| Coordinator | Wire ViewModel callbacks to navigation actions | Decides where to go; calls into the root coordinator |
| Root Coordinator | Own the navigation stack; vend and lifetime-manage feature coordinators | Single source of truth for the stack |

---

## Reference Graph

Use this graph when adding a new feature to verify you are following the correct ownership and reference patterns.

**Arrow legend:**

| Arrow | Meaning |
|---|---|
| `──►` solid | Strong reference (`let` / `var`) |
| `··►` dotted | Unowned reference or closure with `[unowned self]` capture |
| `══►` thick | SwiftUI-managed strong reference (`@State` or `@Bindable`) |

```mermaid
flowchart TD
    classDef app   fill:#dbeafe,stroke:#3b82f6
    classDef coord fill:#fef3c7,stroke:#f59e0b
    classDef cview fill:#ede9fe,stroke:#7c3aed
    classDef vm    fill:#dcfce7,stroke:#16a34a
    classDef view  fill:#fce7f3,stroke:#db2777
    classDef model fill:#f1f5f9,stroke:#64748b

    subgraph APP["App"]
        SA[SakeShopsApp]:::app
        ACV[AppCoordinatorView]:::app
    end

    subgraph COORD["Coordinators"]
        AC[AppCoordinator]:::coord
        HC[HomeCoordinator]:::coord
        SLC[ShopListCoordinator]:::coord
        SDC[ShopDetailCoordinator]:::coord
        MC[MapCoordinator]:::coord
    end

    subgraph CVIEW["CoordinatorViews"]
        HCV[HomeCoordinatorView]:::cview
        SLCV[ShopListCoordinatorView]:::cview
        SDCV[ShopDetailCoordinatorView]:::cview
        MCV[MapCoordinatorView]:::cview
    end

    subgraph VM["ViewModels"]
        HVM[HomeViewModel]:::vm
        SLVM[ShopListViewModel]:::vm
        SDVM[ShopDetailViewModel]:::vm
        MVM[MapViewModel]:::vm
    end

    subgraph VIEW["Views"]
        HV[HomeView]:::view
        SLV[ShopListView]:::view
        SDV[ShopDetailView]:::view
        MV[MapView]:::view
    end

    subgraph MODEL["Core Models"]
        SS[SakeShop]:::model
        ML[MapLocation]:::model
    end

    %% App layer
    SA      -- strong          --> AC
    ACV     == "@Bindable"     ==> AC

    %% AppCoordinator vends feature coordinators (lazy, released when route leaves stack)
    AC      -- "strong (lazy)" --> HC
    AC      -- "strong (lazy)" --> SLC

    %% Feature coordinators hold an unowned back-reference to break the retain cycle
    HC      -. unowned         .-> AC
    SLC     -. unowned         .-> AC
    SDC     -. unowned         .-> AC

    %% Persistent CoordinatorViews receive coordinator as let (AppCoordinator owns lifetime)
    HCV     -- "strong let"    --> HC
    SLCV    -- "strong let"    --> SLC

    %% Ephemeral CoordinatorViews own their coordinator via @State (created inside navigationDestination)
    SDCV    == "@State"        ==> SDC
    MCV     == "@State"        ==> MC

    %% Coordinators own ViewModels
    HC      -- "strong let"    --> HVM
    SLC     -- "strong let"    --> SLVM
    SDC     -- "strong let"    --> SDVM
    MC      -- "strong let"    --> MVM

    %% ViewModels store navigation callbacks; closures capture their coordinator unowned
    HVM     -. "callback [unowned]" .-> HC
    SLVM    -. "callback [unowned]" .-> SLC
    SDVM    -. "callback [unowned]" .-> SDC

    %% Views hold their ViewModel as a plain let (no @Bindable / @State needed)
    HV      -- "strong let"    --> HVM
    SLV     -- "strong let"    --> SLVM
    SDV     -- "strong let"    --> SDVM
    MV      -- "strong let"    --> MVM

    %% ViewModels reference Core Models
    SLVM    -- strong          --> SS
    SDVM    -- strong          --> SS
    MVM     -- strong          --> ML
```

### Checklist for a new feature

1. Add a case to `AppRoute` (carry any model the destination needs as an associated value).
2. Create `XxxCoordinator` — `final class`, `private unowned let app: AppCoordinator`, `let viewModel: XxxViewModel`. Wire `viewModel.onXxx` callbacks to `app.push(...)` in `init`.
3. Create `XxxCoordinatorView` — use `let coordinator:` when `AppCoordinator` owns the lifetime; use `@State private var coordinator:` when the view constructs it inside `navigationDestination`.
4. Create `XxxViewModel` — `@Observable @MainActor final class`. Declare `var onXxx: (Payload) -> Void = { _ in }` for each navigation trigger. Views call named methods (`func xxxTapped()`), never the callback directly.
5. Create `XxxView` — `let model: XxxViewModel`. No `@Bindable`, no `@EnvironmentObject`.
6. Add a `navigationDestination` branch in `AppCoordinatorView`.
7. If the coordinator must survive multiple child views, add a lazy accessor on `AppCoordinator` and call `releaseStaleCoordinators()` when its route is absent from the path.
