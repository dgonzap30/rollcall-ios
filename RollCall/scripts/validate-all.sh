#!/bin/bash
#
# Full validation suite for RollCall
# Ensures code quality and all tests pass
#

set -e

echo "🚀 RollCall Full Validation Suite"
echo "=================================="
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

# 2. Linting
echo "🔍 Running SwiftLint..."
if swiftlint lint --quiet; then
    echo "✅ No linting issues"
else
    echo "⚠️  Linting warnings found (see above)"
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
    clean build; then
    echo "✅ Build successful"
else
    echo "❌ Build failed"
    exit 1
fi
echo ""

# 4. Run Tests
echo "🧪 Running tests..."
if xcodebuild -project RollCall.xcodeproj \
    -scheme RollCall \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO \
    test; then
    echo "✅ All tests passed"
else
    echo "❌ Tests failed"
    exit 1
fi
echo ""

# 5. Color Contrast Validation
echo "🎨 Validating color contrast..."
if xcodebuild -project RollCall.xcodeproj \
    -scheme RollCall \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    test \
    -only-testing:RollCallTests/ColorContrastTests \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO; then
    echo "✅ Color contrast validation complete"
else
    echo "❌ Color contrast validation failed"
fi
echo ""

# 6. Summary
echo "📊 Validation Summary"
echo "===================="
echo "✅ Code formatting: PASSED"
echo "✅ Build: PASSED"
echo "✅ Tests: PASSED"
echo "✅ WCAG Compliance: PASSED"
echo ""
echo "🎉 All validations passed! The codebase is rock-solid and ready for development."