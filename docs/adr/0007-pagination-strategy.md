# ADR 0007: Pagination Strategy

## Status
Accepted

## Date
2026-06-02

## Deciders
Fernando Luna

## Context & Problem Statement

`ShopListViewModel` loads shops page by page. We needed to decide how the ViewModel determines whether more pages exist, how page state is tracked, and what the page size should be. The current API returns an array of shops with no envelope — no `totalCount`, no `nextCursor`, no `hasMore` flag.

## Decision Drivers

* The API response is a bare `[SakeShop]` array with no pagination metadata
* The implementation must be simple enough to replace once the API evolves
* Fetching an unnecessary empty page is acceptable; missing data is not

## Considered Options

* **Option 1: Page number + count heuristic** — Track `currentPage: Int`. After each fetch, set `hasMore = result.count == pageSize`. If the result is smaller than a full page, there are no more items.
* **Option 2: Cursor-based pagination** — The server provides an opaque cursor or offset token with each response; the client passes it back on the next request.
* **Option 3: Prefetch all** — Load all shops in one request with no pagination, relying on the server to return a manageable dataset.

## Decision Outcome

Chosen option: **Option 1**, because the API provides no metadata to support Option 2, and the dataset is too large and open-ended to safely load all at once with Option 3.

### Justification

Cursor-based pagination (Option 2) is the correct long-term solution but requires API changes. Option 3 would work for small, bounded datasets but is inappropriate if the shop catalogue grows — it also pushes dataset-size risk into the client. The count heuristic is a well-known stopgap for bare-array APIs: it is correct in the common case and fails gracefully (one extra empty fetch) in the edge case.

## Pros and Cons of the Chosen Option

### 🟢 Positive Consequences

* No API changes required to ship pagination.
* The implementation is simple: `currentPage` increments by 1; `hasMore` is a single comparison.
* Compatible with any server that accepts `page` + `page_size` query parameters.

### 🔴 Negative Consequences

* **Known edge case:** if the last page contains exactly `pageSize` items, `hasMore` is incorrectly set to `true`. The ViewModel will request one additional page that returns an empty array. This causes a harmless extra network request but no data loss or visible error.
* Page numbers are stateful in the ViewModel — if the shop list is refreshed mid-session, `currentPage` must be reset to 1 (handled in `task()`).
* Must be replaced with a server-provided `hasMore` flag or cursor once the API supports it, to eliminate the edge-case extra request.
