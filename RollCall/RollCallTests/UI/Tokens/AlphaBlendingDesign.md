# Alpha Blending Implementation for Color Contrast Tests

## Overview

This document describes the alpha blending implementation used in RollCall's color contrast tests to ensure accurate WCAG compliance validation when colors have transparency.

## The Problem

SwiftUI colors can have opacity values less than 1.0, creating semi-transparent colors. When calculating contrast ratios for WCAG compliance, we need to account for how these transparent colors will appear when rendered over a background color.

Simply using the color's RGB values without considering opacity would give incorrect contrast ratios, potentially leading to accessibility violations in the app.

## The Solution

### Alpha Compositing Formula

We implement the Porter-Duff "over" operation, which is the standard alpha compositing formula used by graphics systems:

```
resultColor = foregroundColor * foregroundAlpha + backgroundColor * (1 - foregroundAlpha)
```

This formula is applied to each RGB channel independently.

### Implementation Details

1. **Alpha Blending Function**
   - Takes foreground and background colors with RGBA components
   - Handles edge cases (alpha = 0, alpha = 1, invalid alpha values)
   - Clamps all values to valid ranges [0, 1]
   - Returns the blended RGB values

2. **Contrast Ratio Calculation**
   - Detects when foreground color has transparency (alpha < 1.0)
   - Applies alpha blending before calculating luminance
   - Uses standard WCAG contrast ratio formula on the blended result

3. **Edge Case Handling**
   - Alpha = 0: Returns background color (fully transparent)
   - Alpha = 1: Returns foreground color (fully opaque)
   - Invalid alpha values: Clamped to [0, 1] range
   - Invalid RGB values: Clamped to [0, 1] range

## Test Coverage

The implementation includes comprehensive tests for:

1. **Basic Alpha Blending**
   - 50% black on white → gray with ~3.95:1 contrast
   - Verifies the mathematical correctness of blending

2. **Multiple Opacity Levels**
   - Tests opacity levels: 1.0, 0.8, 0.6, 0.4, 0.2
   - Confirms contrast decreases as opacity decreases
   - Validates monotonic relationship

3. **Edge Cases**
   - Fully transparent (alpha = 0)
   - Negative opacity values
   - Opacity values > 1.0
   - All edge cases properly handled

4. **Real-World Scenarios**
   - Disabled text (38% opacity)
   - Hover overlays (8% black)
   - Focus rings (25% colored)
   - Common UI patterns validated

## Usage in Tests

When testing color combinations with transparency:

```swift
// Example: Testing 60% opacity text
let textColor = Color.rcSoy600.opacity(0.6)
let backgroundColor = Color.rcRice50

let ratio = contrastRatio(between: textColor, and: backgroundColor)
// This will:
// 1. Detect the 0.6 alpha
// 2. Blend rcSoy600 with rcRice50
// 3. Calculate contrast on the blended result
```

## SwiftUI Considerations

SwiftUI's `.opacity()` modifier creates colors with the specified alpha channel. Our implementation correctly handles these cases to ensure accurate accessibility testing.

### Important Notes

1. Background colors are assumed to be opaque
2. Nested transparency (transparent on transparent) is not currently supported
3. The implementation matches the visual rendering in SwiftUI

## Future Enhancements

Potential improvements for more complex scenarios:

1. Support for gradient backgrounds (test at multiple points)
2. Nested transparency calculations
3. Pattern/texture background support
4. Animation state testing (varying opacity)

## References

- [WCAG 2.2 Contrast Requirements](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum)
- [Porter-Duff Compositing Operations](https://en.wikipedia.org/wiki/Alpha_compositing)
- [CSS Color Module Level 4 - Transparency](https://www.w3.org/TR/css-color-4/#transparency)