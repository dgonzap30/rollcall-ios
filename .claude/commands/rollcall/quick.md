# Quick RollCall Validation

Perform rapid validation of format and lint only (no build/test).

Usage: `/quick`

## Quick Checks:

1. **SwiftFormat Check**:
   ```bash
   cd RollCall
   swiftformat --lint .
   ```
   
2. **SwiftLint Check**:
   ```bash
   cd RollCall
   swiftlint
   ```

3. **Report Results**:
   - ✅ Pass: 0 violations, no formatting issues
   - ⚠️ Warning: Minor issues that can be auto-fixed
   - ❌ Fail: Violations that need manual intervention

## Auto-Fix Option:

If issues are found, offer to auto-fix:
```bash
# Auto-format code
swiftformat .

# Auto-correct lint violations
swiftlint autocorrect
```

## Common Quick Fixes:

### Trailing Commas
Remove all trailing commas from collections:
```swift
// ❌ Wrong
let array = [
    "item1",
    "item2",  // Remove this comma
]

// ✅ Correct
let array = [
    "item1",
    "item2"
]
```

### Line Length
Break long lines at logical points:
```swift
// ❌ Wrong (>120 chars)
let message = "This is a very long string that exceeds the maximum line length and needs to be broken up"

// ✅ Correct
let message = "This is a very long string that exceeds the " +
              "maximum line length and needs to be broken up"
```

### Opening Braces
Keep opening braces on same line:
```swift
// ❌ Wrong
if condition
{
    doSomething()
}

// ✅ Correct  
if condition {
    doSomething()
}
```

This is the fastest validation - takes <5 seconds and catches most common issues before commit.