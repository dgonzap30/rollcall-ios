# RollCall Morning Routine

Start your RollCall development day with a comprehensive status check and setup.

Usage: `/morning`

## Morning Checklist:

1. **Pull Latest Changes**:
   ```bash
   git fetch origin
   git status
   # Show any new commits
   git log HEAD..origin/main --oneline
   ```

2. **Check Current Status**:
   - Current P0 item in progress
   - Any blockers from yesterday
   - CI status from overnight builds
   - Outstanding PRs to review

3. **Update Metrics**:
   - Generate fresh ci-metrics.json
   - Check coverage trends
   - Verify SwiftLint compliance
   - Test suite health

4. **Validate Workspace**:
   ```bash
   # Quick format and lint check
   cd RollCall
   swiftformat --lint .
   swiftlint
   
   # Ensure project builds
   xcodebuild -project RollCall.xcodeproj -scheme RollCall build
   ```

5. **Review P0 Progress**:
   - List remaining P0 items for MVP
   - Check dependencies and blockers
   - Identify today's focus item

6. **Setup Development Environment**:
   - Open Xcode project
   - Start iOS Simulator
   - Ensure all tools available

## Morning Report Format:
```
🌅 RollCall Morning Status
==========================
Last sync: 2 hours ago (3 new commits)

📊 Metrics:
  Build: ✅ Green
  Tests: ✅ Passing (73.6% coverage)
  Lint: ✅ Clean
  
🎯 Current Focus:
  P0-015: Implement feed pagination
  Status: In Progress (50% complete)
  
📋 Today's Goals:
  1. Complete pagination implementation
  2. Write integration tests
  3. Fix PR feedback from yesterday
  
⚠️ Attention Needed:
  - PR #45 awaiting your review
  - Coverage dropped 2% yesterday
  
🚀 Ready to start coding!
```

## Quick Actions:
After morning routine, common next steps:
- `/code` - Continue current P0 implementation
- `/review` - Review pending PRs
- `/fix` - Address any failing checks
- `/p0 next` - Start new P0 if current is complete

This command helps ensure you start each day with full context and a clean workspace.