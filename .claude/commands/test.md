Run the SakeShops unit tests filtered to a specific feature.

$ARGUMENTS is the feature name (e.g. `ShopList`, `ShopDetail`, `Home`, `Map`).

Steps:
1. Find every test suite file under `SakeShopsTests/Features/$ARGUMENTS/` using `find`.
2. For each file found, derive the suite name from the filename (strip `.swift`).
3. Build a single `xcodebuild test` command that passes one `-only-testing:SakeShopsTests/<SuiteName>` flag per suite.
4. Run it and report only the pass/fail lines (grep for `✔` and `✘` and the final summary line).

Example for `/test ShopList`:
- Finds: ShopListViewModelTests, ShopListCoordinatorTests, ShopListServiceTests, SakeShopDecodingTests
- Runs: xcodebuild test ... -only-testing:SakeShopsTests/ShopListViewModelTests -only-testing:SakeShopsTests/ShopListCoordinatorTests ...

Use this xcodebuild invocation template:
```
xcodebuild test -project SakeShops.xcodeproj -scheme SakeShops \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  <-only-testing flags> 2>&1 | grep -E "✔|✘|passed|failed|error:"
```
