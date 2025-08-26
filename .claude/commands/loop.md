# RollCall P0 Loop Cycle

Run the full P0 development cycle for RollCall:

1. **Collect Metrics**: Generate CI metrics from current codebase state
2. **Run Architect**: Update ROADMAP anchors and generate P0 Plan
3. **Implement P0**: Code the next P0 item using TDD
4. **Review**: Run code review on implementation
5. **Fix Issues**: Address any review findings
6. **Validate**: Ensure all tests pass and lint is clean

## Steps to Execute:

1. First, collect current metrics:
   - Run `xcodebuild -project RollCall/RollCall.xcodeproj -scheme RollCall build` to check build status
   - Run `swiftlint` in RollCall directory to count violations
   - Generate ci-metrics.json with results

2. Use the rollcall-architect agent to:
   - Read current ROADMAP.md anchors
   - Analyze ci-metrics.json
   - Update P0_TASKS, METRICS, CHANGELOG, MACHINE_STATE anchors
   - Generate P0 Plan JSON

3. Use the rollcall-swift-coder agent to:
   - Implement the next P0 item from the plan
   - Follow TDD approach
   - Create PR with proper DoD checklist

4. Use the rollcall-code-reviewer agent to:
   - Review the implementation
   - Check MVVM-C compliance
   - Verify test coverage

5. If issues found, use rollcall-swift-coder to fix them

6. Run final validation:
   - `swiftformat .` in RollCall directory
   - `swiftlint` with 0 violations required
   - `xcodebuild test` to ensure all tests pass

The loop continues until all P0 items are complete or MVP is achieved.