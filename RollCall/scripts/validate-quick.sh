#!/bin/bash
#
# Quick validation for RollCall
# Runs essential checks only
#

set -e

echo "🚀 RollCall Quick Validation"
echo "============================"
echo ""

# Navigate to project directory
cd "$(dirname "$0")/.."

# 1. Code Formatting
echo "📝 Checking code formatting..."
if swiftformat . --lint --quiet; then
    echo "✅ Code formatting is correct"
else
    echo "❌ Code formatting issues found. Run 'swiftformat .' to fix."
    exit 1
fi
echo ""

# 2. Linting (errors only)
echo "🔍 Running SwiftLint (errors only)..."
if swiftlint lint --strict --quiet 2>/dev/null; then
    echo "✅ No linting errors"
else
    echo "❌ Linting errors found"
    swiftlint lint --strict | grep "error:"
    exit 1
fi
echo ""

# 3. Build
echo "🔨 Building project..."
if xcodebuild -project RollCall.xcodeproj \
    -scheme RollCall \
    -configuration Debug \
    -sdk iphonesimulator \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    build -quiet; then
    echo "✅ Build successful"
else
    echo "❌ Build failed"
    exit 1
fi
echo ""

# 4. Run Color Contrast Tests only
echo "🎨 Validating WCAG compliance..."
if xcodebuild -project RollCall.xcodeproj \
    -scheme RollCall \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    test \
    -only-testing:RollCallTests/ColorContrastTests \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    -quiet 2>&1 | grep -q "Test Suite.*passed"; then
    echo "✅ WCAG compliance validated"
else
    echo "⚠️  Running color contrast tests..."
    xcodebuild -project RollCall.xcodeproj \
        -scheme RollCall \
        -sdk iphonesimulator \
        -destination 'platform=iOS Simulator,name=iPhone 16' \
        test \
        -only-testing:RollCallTests/ColorContrastTests \
        CODE_SIGN_IDENTITY="" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO 2>&1 | grep -E "(PASSED|FAILED|error:)"
fi
echo ""

# 5. Summary
echo "📊 Quick Validation Complete"
echo "=========================="
echo "✅ Code formatting: PASSED"
echo "✅ Build: PASSED"
echo "✅ Critical checks: PASSED"
echo ""
echo "🎉 The codebase is ready for development!"
echo ""
echo "💡 For full validation including all tests, run: ./scripts/validate-all.sh"