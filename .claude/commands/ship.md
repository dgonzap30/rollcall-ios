# Ship RollCall Changes

Prepare and ship changes for production deployment.

Usage: `/ship [feature|hotfix|release]`

## Ship Process:

1. **Pre-flight Checks**:
   - Ensure on correct branch
   - No uncommitted changes
   - All tests passing
   - Zero SwiftLint violations
   - Coverage meets threshold

2. **Validation Suite**:
   ```bash
   # Format check
   swiftformat --lint RollCall/
   
   # Lint check (must be 0)
   cd RollCall && swiftlint
   
   # Build check
   xcodebuild -project RollCall/RollCall.xcodeproj -scheme RollCall build
   
   # Test suite
   xcodebuild -project RollCall/RollCall.xcodeproj -scheme RollCall test
   ```

3. **Update Version** (if release):
   - Bump version in Info.plist
   - Update CHANGELOG.md
   - Tag release

4. **Create PR**:
   ```bash
   # Create feature branch if needed
   git checkout -b feat/RC-P0-###-description
   
   # Stage changes
   git add .
   
   # Commit with conventional format
   git commit -m "feat(module): description
   
   - Implementation details
   - Meets DoD criteria
   - Tests included"
   
   # Push to remote
   git push -u origin $(git branch --show-current)
   
   # Create PR via gh CLI
   gh pr create --title "feat: Description" --body "..."
   ```

5. **Deployment Preparation**:
   - Build Release configuration
   - Generate dSYMs for crash reporting
   - Create release notes
   - Prepare TestFlight submission

## Ship Types:

### Feature Ship (`/ship feature`)
- Complete P0 implementation
- All tests passing
- PR ready for review
- DoD checklist complete

### Hotfix Ship (`/ship hotfix`)
- Critical bug fix
- Minimal change scope
- Fast-track review
- Direct to main branch

### Release Ship (`/ship release`)
- Version bump
- Full regression test
- Release notes generated
- TestFlight submission ready

## DoD Checklist:
- [ ] Code builds without warnings
- [ ] All tests pass (>80% coverage)
- [ ] SwiftLint: 0 violations
- [ ] SwiftFormat: No changes needed
- [ ] Accessibility labels present
- [ ] Design tokens used consistently
- [ ] Memory leaks checked
- [ ] PR description complete
- [ ] Screenshots included (if UI)

## Arguments:
- "feature" - Ship feature branch
- "hotfix" - Ship emergency fix
- "release" - Ship version release
- No arguments - Detect from branch name