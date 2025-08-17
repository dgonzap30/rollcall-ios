#!/bin/bash
#
# Test color contrast ratios
# This script builds and runs the color contrast tests
#

set -e

echo "🎨 Running Color Contrast Tests..."
echo "=================================="

# Navigate to project directory
cd "$(dirname "$0")/.."

# Build and test with proper settings
xcodebuild \
  -project RollCall.xcodeproj \
  -scheme RollCall \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  test \
  -only-testing:RollCallTests/ColorContrastTests \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  2>&1 | xcpretty --test --color || true

echo ""
echo "✅ Color contrast testing complete"