# Fix RollCall Code Issues

Automatically fix common code issues or review findings.

Usage: `/fix [ci|timeout|lint|review|all]`

## Fix Modes:

### CI Issues (`/fix ci`)
Diagnose and fix CI pipeline failures:

1. **Check Build Status**:
   ```bash
   xcodebuild -project RollCall/RollCall.xcodeproj -scheme RollCall build
   ```

2. **Fix Common Issues**:
   - **Lint violations**: Run `swiftformat .` then `swiftlint autocorrect`
   - **Import errors**: Check and fix module imports
   - **Type errors**: Fix type mismatches and missing protocol conformances
   - **Test failures**: Fix failing assertions and expectations

3. **Verify Fix**:
   - Re-run build and tests
   - Ensure SwiftLint shows 0 violations

### Test Timeouts (`/fix timeout`)
Fix hanging tests that exceed timeout:

1. **Identify Timeout Issues**:
   - Find tests with `expectation.fulfill()` but no `waitForExpectations`
   - Look for infinite loops in async tests
   - Check for missing `Task.checkCancellation()`

2. **Apply Fixes**:
   - Add `waitForExpectations(timeout: 5.0)`
   - Add `executionTimeAllowance = 60.0` in setUp()
   - Ensure async tests properly await

### Lint Violations (`/fix lint`)
Auto-fix SwiftLint violations:

1. **Format Code**:
   ```bash
   cd RollCall && swiftformat .
   ```

2. **Auto-correct Violations**:
   ```bash
   cd RollCall && swiftlint autocorrect
   ```

3. **Fix Remaining Issues**:
   - Remove trailing commas in collections
   - Fix line length violations
   - Correct opening brace placement
   - Remove unused variables

### Review Findings (`/fix review`)
Fix issues found in code review:

1. **Read Latest Review**:
   - Get findings from last review
   - Prioritize by severity

2. **Apply Fixes**:
   - Add missing [weak self] in closures
   - Replace hard-coded values with constants
   - Add accessibility labels
   - Fix MVVM-C violations

### All Issues (`/fix all`)
Run all fix modes in sequence:
1. Fix CI issues first (blocks everything)
2. Fix timeouts (blocks tests)
3. Fix lint violations (blocks commit)
4. Fix review findings (improves quality)

## Arguments:
- "ci" - Fix CI/build failures
- "timeout" - Fix test timeout issues
- "lint" - Fix SwiftLint violations
- "review" - Fix code review findings
- "all" - Fix everything in order
- No arguments defaults to "all"

## Success Criteria:
- ✅ Build succeeds without warnings
- ✅ All tests pass
- ✅ SwiftLint: 0 violations
- ✅ No review blockers remaining