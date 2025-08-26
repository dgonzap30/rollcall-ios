# RollCall Validation Suite

Run validation checks on the RollCall codebase. 

Usage: `/validate [quick|build|full|smart]`

Default mode is "smart" which intelligently determines what to validate based on changed files.

## Validation Modes:

### Quick (format + lint only)
1. Run SwiftFormat lint check: `swiftformat --lint RollCall/`
2. Run SwiftLint: `cd RollCall && swiftlint`
3. Report any violations found

### Build (quick + compilation)
1. Run Quick validation first
2. Build main target: `xcodebuild -project RollCall/RollCall.xcodeproj -scheme RollCall build`
3. Report any build errors or warnings

### Full (build + tests)
1. Run Build validation first
2. Run all tests: `xcodebuild -project RollCall/RollCall.xcodeproj -scheme RollCall test`
3. Report test results and coverage

### Smart (intelligent based on changes)
1. Check git for changed files: `git diff --name-only HEAD`
2. If Swift files changed:
   - Run Quick validation
   - If test files changed: Run Full validation
   - Otherwise: Run Build validation
3. If no changes: Report "No changes to validate"

## Arguments:
- If $ARGUMENTS is "quick", "build", "full", or "smart", use that mode
- If no arguments, default to "smart"

## Success Criteria:
- ✅ SwiftFormat: No formatting issues
- ✅ SwiftLint: 0 violations
- ✅ Build: Compiles without warnings
- ✅ Tests: All passing with >60% coverage (MVP), >80% (Beta)