#!/bin/bash

# Local CI Validation Script
# Run this before pushing to ensure CI will pass

set -e

echo "🍣 RollCall Local CI Validation"
echo "================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Status tracking
FAILED=0

print_section() {
    echo -e "${BLUE}▶ $1${NC}"
    echo "-------------------"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
    FAILED=1
}

# 1. SwiftFormat Check
print_section "SwiftFormat Check"
if swiftformat --lint . --quiet; then
    print_success "SwiftFormat: No formatting issues"
else
    print_error "SwiftFormat: Formatting issues found"
    echo "Run 'swiftformat .' to fix"
fi
echo ""

# 2. SwiftLint Check
print_section "SwiftLint Check"
LINT_OUTPUT=$(swiftlint lint --quiet --reporter json 2>/dev/null || true)
if [ -z "$LINT_OUTPUT" ] || [ "$LINT_OUTPUT" = "[]" ]; then
    print_success "SwiftLint: 0 violations"
else
    VIOLATIONS=$(echo "$LINT_OUTPUT" | jq 'length' 2>/dev/null || echo "unknown")
    print_error "SwiftLint: $VIOLATIONS violations found"
    echo "Run 'swiftlint' to see details"
fi
echo ""

# 3. Build Check
print_section "Build Check"
echo "Building project..."
if xcodebuild clean build \
    -project RollCall.xcodeproj \
    -scheme RollCall \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    -quiet \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    ONLY_ACTIVE_ARCH=YES > /dev/null 2>&1; then
    print_success "Build: Succeeded"
else
    print_error "Build: Failed"
    echo "Run 'xcodebuild' to see detailed errors"
fi
echo ""

# 4. Test Build Check
print_section "Test Target Build"
echo "Building test target..."
if xcodebuild build-for-testing \
    -project RollCall.xcodeproj \
    -scheme RollCall \
    -sdk iphonesimulator \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    -quiet \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO > /dev/null 2>&1; then
    print_success "Test Build: Succeeded"
else
    print_error "Test Build: Failed"
fi
echo ""

# 5. Git Status Check
print_section "Git Status"
if [ -n "$(git status --porcelain)" ]; then
    print_warning "Uncommitted changes detected:"
    git status --short
else
    print_success "Working directory clean"
fi
echo ""

# 6. Coverage Check (if tests ran)
print_section "Coverage Check"
if [ -f "TestResults.xcresult" ]; then
    COVERAGE=$(xcrun xccov view --report --json TestResults.xcresult 2>/dev/null | jq '.lineCoverage * 100' | cut -d. -f1)
    if [ "$COVERAGE" -ge 60 ]; then
        print_success "Coverage: ${COVERAGE}% (meets MVP threshold)"
    else
        print_error "Coverage: ${COVERAGE}% (below MVP threshold of 60%)"
    fi
else
    print_warning "No test results found (tests may not have run)"
fi
echo ""

# 7. CI Scripts Check
print_section "CI Scripts"
for script in scripts/*.sh; do
    if [ -x "$script" ]; then
        print_success "$(basename $script) is executable"
    else
        print_error "$(basename $script) is not executable"
        echo "Run: chmod +x $script"
    fi
done
echo ""

# Summary
echo "================================"
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All checks passed!${NC}"
    echo "Your code is ready for CI/CD"
    echo ""
    echo "Next steps:"
    echo "1. Commit your changes: git add . && git commit -m 'your message'"
    echo "2. Push to GitHub: git push"
    echo "3. Create a PR if working on a feature branch"
else
    echo -e "${RED}⚠️  Some checks failed${NC}"
    echo "Please fix the issues above before pushing"
    echo ""
    echo "Quick fixes:"
    echo "- Format code: swiftformat ."
    echo "- See lint issues: swiftlint"
    echo "- Fix permissions: chmod +x scripts/*.sh"
fi
echo "================================"

exit $FAILED