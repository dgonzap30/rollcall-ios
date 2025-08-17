#!/usr/bin/env bash
# Comprehensive validation script for RollCall repository
# Ensures all workflow requirements are met

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
ERRORS=0
WARNINGS=0

echo "🔍 RollCall Repository Validation"
echo "================================="
echo ""

# Function to check if a file exists
check_file() {
    local file=$1
    local description=$2
    if [ -f "$file" ]; then
        echo -e "${GREEN}✅${NC} $description exists"
        return 0
    else
        echo -e "${RED}❌${NC} $description missing: $file"
        ((ERRORS++))
        return 1
    fi
}

# Function to check if a directory exists
check_dir() {
    local dir=$1
    local description=$2
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✅${NC} $description exists"
        return 0
    else
        echo -e "${RED}❌${NC} $description missing: $dir"
        ((ERRORS++))
        return 1
    fi
}

# Function to check for anchor in ROADMAP
check_anchor() {
    local anchor=$1
    if grep -q "<!-- $anchor -->" ROADMAP.md && grep -q "<!-- /$anchor -->" ROADMAP.md; then
        echo -e "${GREEN}✅${NC} ROADMAP anchor: $anchor"
        return 0
    else
        echo -e "${RED}❌${NC} ROADMAP anchor missing: $anchor"
        ((ERRORS++))
        return 1
    fi
}

# 1. Check critical files
echo "📁 Checking critical files..."
check_file "ROADMAP.md" "ROADMAP.md"
check_file "docs/AGENTS.md" "Agent documentation"
check_file "docs/api_v1.md" "API specification stub"
check_file ".github/workflows/ci.yml" "CI workflow"
check_file ".github/pull_request_template.md" "PR template"
check_file "scripts/update_anchors.py" "Anchor update script"
check_file ".swiftlint.yml" "SwiftLint config"
check_file ".swiftformat" "SwiftFormat config"
echo ""

# 2. Check ROADMAP anchors
echo "⚓ Checking ROADMAP anchors..."
check_anchor "P0_TASKS"
check_anchor "METRICS"
check_anchor "CHANGELOG"
check_anchor "MACHINE_STATE"
echo ""

# 3. Check directory structure
echo "📂 Checking directory structure..."
check_dir "RollCall" "Main project directory"
check_dir "RollCall/RollCall" "Source code directory"
check_dir "RollCall/RollCallTests" "Tests directory"
check_dir ".github/workflows" "GitHub workflows"
check_dir "scripts" "Scripts directory"
check_dir "docs" "Documentation directory"
echo ""

# 4. Check Xcode project
echo "🔨 Checking Xcode project..."
if [ -d "RollCall/RollCall.xcodeproj" ]; then
    echo -e "${GREEN}✅${NC} Xcode project exists"
    
    # Check for shared schemes
    if [ -f "RollCall/RollCall.xcodeproj/xcshareddata/xcschemes/RollCall.xcscheme" ]; then
        echo -e "${GREEN}✅${NC} Shared scheme exists"
        
        # Check if code coverage is enabled
        if grep -q "codeCoverageEnabled = \"YES\"" "RollCall/RollCall.xcodeproj/xcshareddata/xcschemes/RollCall.xcscheme"; then
            echo -e "${GREEN}✅${NC} Code coverage enabled"
        else
            echo -e "${YELLOW}⚠️${NC} Code coverage might not be enabled"
            ((WARNINGS++))
        fi
    else
        echo -e "${RED}❌${NC} Shared scheme missing"
        ((ERRORS++))
    fi
else
    echo -e "${RED}❌${NC} Xcode project missing"
    ((ERRORS++))
fi
echo ""

# 5. Check SwiftLint
echo "🧹 Checking SwiftLint..."
cd RollCall
if command -v swiftlint &> /dev/null; then
    LINT_COUNT=$(swiftlint --quiet 2>/dev/null | wc -l | tr -d ' ')
    if [ "$LINT_COUNT" -eq 0 ]; then
        echo -e "${GREEN}✅${NC} SwiftLint: 0 violations"
    else
        echo -e "${YELLOW}⚠️${NC} SwiftLint: $LINT_COUNT violations"
        ((WARNINGS++))
    fi
else
    echo -e "${RED}❌${NC} SwiftLint not installed"
    ((ERRORS++))
fi
cd ..
echo ""

# 6. Check SwiftFormat
echo "🎨 Checking SwiftFormat..."
if command -v swiftformat &> /dev/null; then
    FORMAT_ERRORS=$(swiftformat --lint . 2>&1 | grep -c "error:" || true)
    if [ "$FORMAT_ERRORS" -eq 0 ]; then
        echo -e "${GREEN}✅${NC} SwiftFormat: Clean"
    else
        echo -e "${YELLOW}⚠️${NC} SwiftFormat: $FORMAT_ERRORS errors"
        ((WARNINGS++))
    fi
else
    echo -e "${RED}❌${NC} SwiftFormat not installed"
    ((ERRORS++))
fi
echo ""

# 7. Check if tests compile
echo "🧪 Checking test compilation..."
cd RollCall
if xcodebuild -scheme RollCall -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 16' build-for-testing &> /dev/null; then
    echo -e "${GREEN}✅${NC} Tests compile successfully"
else
    echo -e "${RED}❌${NC} Test compilation failed"
    ((ERRORS++))
fi
cd ..
echo ""

# 8. Check for Info.plist privacy strings
echo "🔐 Checking privacy strings..."
if [ -f "RollCall/RollCall/Info.plist" ]; then
    if grep -q "NSPhotoLibraryUsageDescription" "RollCall/RollCall/Info.plist"; then
        echo -e "${GREEN}✅${NC} NSPhotoLibraryUsageDescription present"
    else
        echo -e "${YELLOW}⚠️${NC} NSPhotoLibraryUsageDescription missing"
        ((WARNINGS++))
    fi
    
    if grep -q "NSPhotoLibraryAddUsageDescription" "RollCall/RollCall/Info.plist"; then
        echo -e "${GREEN}✅${NC} NSPhotoLibraryAddUsageDescription present"
    else
        echo -e "${YELLOW}⚠️${NC} NSPhotoLibraryAddUsageDescription missing"
        ((WARNINGS++))
    fi
    
    if grep -q "NSCameraUsageDescription" "RollCall/RollCall/Info.plist"; then
        echo -e "${GREEN}✅${NC} NSCameraUsageDescription present"
    else
        echo -e "${YELLOW}⚠️${NC} NSCameraUsageDescription missing"
        ((WARNINGS++))
    fi
else
    # Check if using auto-generated Info.plist
    if grep -q "GENERATE_INFOPLIST_FILE = YES" "RollCall/RollCall.xcodeproj/project.pbxproj"; then
        echo -e "${YELLOW}⚠️${NC} Using auto-generated Info.plist (privacy strings may be missing)"
        ((WARNINGS++))
    fi
fi
echo ""

# 9. Check CI configuration
echo "🚀 Checking CI configuration..."
if [ -f ".github/workflows/ci.yml" ]; then
    if grep -q "ci-metrics.json" ".github/workflows/ci.yml"; then
        echo -e "${GREEN}✅${NC} CI exports metrics artifact"
    else
        echo -e "${RED}❌${NC} CI doesn't export metrics artifact"
        ((ERRORS++))
    fi
    
    if grep -q "xcodebuild.*test" ".github/workflows/ci.yml"; then
        echo -e "${GREEN}✅${NC} CI runs tests"
    else
        echo -e "${RED}❌${NC} CI doesn't run tests"
        ((ERRORS++))
    fi
fi
echo ""

# 10. Optional: Try to calculate coverage
echo "📊 Checking test coverage..."
if [ -d "../test-results.xcresult" ]; then
    COVERAGE=$(xcrun xccov view --report --json ../test-results.xcresult 2>/dev/null | \
        jq '[.targets[].lineCoverage // 0] | add / length * 100' 2>/dev/null || echo "0")
    if (( $(echo "$COVERAGE > 60" | bc -l) )); then
        echo -e "${GREEN}✅${NC} Test coverage: ${COVERAGE}% (≥60% target)"
    else
        echo -e "${YELLOW}⚠️${NC} Test coverage: ${COVERAGE}% (<60% target)"
        ((WARNINGS++))
    fi
else
    echo -e "${YELLOW}⚠️${NC} No test results found (run tests first)"
fi
echo ""

# Summary
echo "📈 Validation Summary"
echo "===================="
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}🎉 Perfect! Repository is fully compliant with workflow requirements.${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}✅ Repository meets minimum requirements with $WARNINGS warnings.${NC}"
    exit 0
else
    echo -e "${RED}❌ Repository has $ERRORS errors and $WARNINGS warnings.${NC}"
    echo -e "${RED}   Fix errors before proceeding with iterative workflow.${NC}"
    exit 1
fi