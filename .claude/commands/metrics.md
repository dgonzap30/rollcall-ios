# Generate RollCall CI Metrics

Generate comprehensive metrics for the RollCall project to track progress toward MVP.

Usage: `/metrics [quick|full|export]`

## Metrics Collection:

### Build Status
```bash
# Main target build
xcodebuild -project RollCall/RollCall.xcodeproj -scheme RollCall -configuration Debug build

# Test target build
xcodebuild -project RollCall/RollCall.xcodeproj -scheme RollCall -configuration Debug build-for-testing
```

### Test Coverage
```bash
# Run tests with coverage
xcodebuild -project RollCall/RollCall.xcodeproj -scheme RollCall -enableCodeCoverage YES test

# Extract coverage percentage
xcrun xccov view --report --json RollCall.xcresult | jq '.lineCoverage'
```

### Code Quality
```bash
# SwiftLint violations count
cd RollCall && swiftlint --reporter json | jq '[.[] | select(.severity != "info")] | length'

# SwiftFormat issues
swiftformat --lint RollCall/ | grep -c "would"
```

### Codebase Statistics
- Total Swift files
- Lines of code
- Test files count
- Test to code ratio

## Output Format:

Generate `ci-metrics.json`:
```json
{
  "timestamp": "2024-01-15T10:30:00Z",
  "build_main": "green",
  "build_tests": "green", 
  "coverage_percent": 73.6,
  "swiftlint_remaining": 0,
  "test_failures": [],
  "statistics": {
    "total_files": 145,
    "total_lines": 12500,
    "test_files": 48,
    "test_coverage": 73.6
  },
  "p0_progress": {
    "completed": 14,
    "in_progress": 1,
    "remaining": 5,
    "blocked": 0
  }
}
```

## Modes:

### Quick (`/metrics quick`)
- Build status only
- SwiftLint count
- Basic pass/fail

### Full (`/metrics full` or `/metrics`)
- Complete build and test
- Coverage calculation
- Detailed statistics
- P0 progress tracking

### Export (`/metrics export`)
- Generate full metrics
- Create markdown report
- Include trend analysis
- Ready for stakeholder review

## Success Thresholds:
- **MVP**: Coverage ≥60%, SwiftLint=0
- **Beta**: Coverage ≥80%, SwiftLint=0
- **Release**: Coverage ≥90%, All metrics green

The metrics are used by the architect agent to make decisions about the next P0 items.