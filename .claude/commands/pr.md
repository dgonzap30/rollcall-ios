# Prepare RollCall Pull Request

Prepare a pull request with all checks passing and proper documentation.

Usage: `/pr [create|check|update]`

## PR Preparation:

### 1. Pre-PR Validation
Run complete validation suite:
```bash
# Format code
cd RollCall && swiftformat .

# Lint check (must be 0 violations)
swiftlint

# Build without warnings
xcodebuild -project RollCall.xcodeproj -scheme RollCall build

# Run all tests
xcodebuild -project RollCall.xcodeproj -scheme RollCall test
```

### 2. Review Changes
```bash
# Check what will be included
git status
git diff --staged
git diff origin/main...HEAD

# Ensure no sensitive data
git diff --staged | grep -i "password\|secret\|key\|token"
```

### 3. Create PR (`/pr create`)

Generate PR with proper format:

**Title Format**: 
`feat(module): Brief description (RC-P0-###)`

**Body Template**:
```markdown
## Summary
Brief description of changes and why they were made.

## P0 Item
**ID**: RC-P0-###
**Title**: [Title from P0 Plan]
**Deliverables**: 
- [ ] Implementation complete
- [ ] Tests written and passing
- [ ] Documentation updated

## Changes Made
- Added new ViewModel for...
- Implemented service for...
- Fixed bug where...

## Testing
- [x] Unit tests added/updated
- [x] Integration tests passing
- [x] Manual testing completed
- Coverage: 85%

## DoD Checklist
- [x] Code builds without warnings
- [x] All tests pass
- [x] SwiftLint: 0 violations
- [x] SwiftFormat: No changes needed
- [x] Accessibility labels present
- [x] Design tokens used
- [x] No force unwrapping (except tests)
- [x] Memory leaks checked
- [x] iOS 15+ compatible

## Screenshots
[If UI changes, include before/after screenshots]

## Dependencies
- No new dependencies added
- [Or list any new packages]

## Review Focus
Please pay special attention to:
- MVVM-C architecture compliance
- Proper error handling in...
- Test coverage for edge cases
```

### 4. Create and Push
```bash
# Create PR via GitHub CLI
gh pr create \
  --title "feat(feed): implement pagination (RC-P0-015)" \
  --body "$(cat pr-body.md)" \
  --base main \
  --label "p0,needs-review"
```

### 5. PR Checks (`/pr check`)
Verify PR is ready:
- CI checks passing
- No merge conflicts
- Review requested from team
- Labels applied correctly
- Linked to P0 issue

### 6. Update PR (`/pr update`)
After review feedback:
1. Address all comments
2. Re-run validation
3. Push updates
4. Request re-review

## Quick Commands:
- `/pr` - Run validation and show PR readiness
- `/pr create` - Create new PR with template
- `/pr check` - Verify PR status and CI
- `/pr update` - Update PR after changes

## Success Criteria:
✅ All CI checks green
✅ No merge conflicts
✅ PR template complete
✅ At least one approval
✅ Ready to merge