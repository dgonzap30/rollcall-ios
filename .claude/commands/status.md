# RollCall Development Status

Show the current RollCall development status including:
- Current P0 item being worked on
- Build status (main and tests)
- Test coverage percentage
- SwiftLint violations count
- Any blockers or issues

## Steps:

1. Check for ci-metrics.json and read:
   - build_main status (green/yellow/red)
   - build_tests status (green/yellow/red)
   - coverage_percent
   - swiftlint_remaining count
   - test_failures array

2. Read ROADMAP.md to identify:
   - Current P0 items in progress
   - Recently completed items from CHANGELOG
   - Overall progress toward MVP

3. Run quick validation checks:
   - `xcodebuild -project RollCall/RollCall.xcodeproj -scheme RollCall -configuration Debug build` 
   - Count SwiftLint violations: `cd RollCall && swiftlint | grep -c "warning\|error"`

4. Display summary:
   ```
   📊 RollCall Development Status
   ================================
   Build Main: ✅ green
   Build Tests: ✅ green
   Coverage: 73.6%
   Lint: ⚠️ 12 violations
   
   Current P0: RC-P0-015 (Implement feed pagination)
   Progress: 14/20 P0 items complete
   
   Next Steps:
   - Complete feed pagination implementation
   - Fix remaining SwiftLint violations
   - Increase test coverage to 80%
   ```

If $ARGUMENTS is provided, show detailed status for that specific aspect (e.g., `/status coverage`, `/status p0`, `/status build`)