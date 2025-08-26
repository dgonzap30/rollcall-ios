# RollCall Emergency Recovery

Emergency recovery when something is critically broken.

Usage: `/panic [build|test|merge|deploy]`

## Emergency Procedures:

### 1. Assess the Situation
```bash
# Check what's broken
git status
git diff
xcodebuild -project RollCall/RollCall.xcodeproj -scheme RollCall build 2>&1 | head -50
```

### 2. Common Panic Scenarios:

#### Build Completely Broken (`/panic build`)
```bash
# Clean all build artifacts
xcodebuild -project RollCall/RollCall.xcodeproj clean
rm -rf ~/Library/Developer/Xcode/DerivedData/RollCall-*

# Reset package dependencies
xcodebuild -resolvePackageDependencies

# Try fresh build
xcodebuild -project RollCall/RollCall.xcodeproj -scheme RollCall build
```

#### Tests Won't Stop/Timeout (`/panic test`)
```bash
# Kill any hanging test processes
pkill -f xctest
pkill -f xcodebuild

# Find and fix test timeouts
grep -r "expectation.fulfill()" RollCall/**/*Tests.swift | grep -v "waitForExpectations"

# Add timeout handling to problematic tests
# Set executionTimeAllowance = 60.0 in setUp()
```

#### Bad Merge Conflicts (`/panic merge`)
```bash
# Stash current changes
git stash

# Reset to last known good state
git reset --hard origin/main

# Cherry-pick good commits if needed
git cherry-pick <commit-hash>
```

#### Failed Deployment (`/panic deploy`)
```bash
# Rollback to previous version
git checkout tags/last-release

# Create hotfix branch
git checkout -b hotfix/emergency-fix

# Apply minimal fix
# Test thoroughly
# Ship directly to main
```

### 3. Recovery Steps:

1. **Stop the Bleeding**:
   - Identify what's broken
   - Revert problematic changes if needed
   - Get to green state ASAP

2. **Fix Root Cause**:
   - Understand what went wrong
   - Apply proper fix
   - Add tests to prevent recurrence

3. **Verify Everything**:
   ```bash
   # Full validation
   swiftformat .
   swiftlint
   xcodebuild -project RollCall.xcodeproj -scheme RollCall build
   xcodebuild -project RollCall.xcodeproj -scheme RollCall test
   ```

4. **Document Incident**:
   - What broke
   - How it was fixed
   - Prevention measures

## Quick Fixes Toolbox:

### SwiftLint Explosion
```bash
cd RollCall
swiftformat .
swiftlint autocorrect
# Manually fix remaining issues
```

### Import Errors
```bash
# Check for missing imports
grep -r "Cannot find type" .
# Add missing: import Foundation, import SwiftUI, etc.
```

### Simulator Issues
```bash
# Reset simulator
xcrun simctl shutdown all
xcrun simctl erase all
```

### Xcode Acting Weird
```bash
# Nuclear option - reset everything
rm -rf ~/Library/Developer/Xcode/DerivedData
rm -rf ~/Library/Caches/com.apple.dt.Xcode
# Restart Xcode
```

## When All Else Fails:
1. Take a deep breath
2. Check recent commits: `git log --oneline -10`
3. Revert to last known good: `git reset --hard <good-commit>`
4. Start over with smaller changes
5. Ask for help with specific error messages

Remember: It's better to have a working codebase with reverted changes than a broken one with new features.