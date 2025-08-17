#!/bin/bash
# Test script for RollCall
set -e

echo "🧪 Running RollCall Tests..."

# Navigate to RollCall directory
cd "$(dirname "$0")/../RollCall"

# Clean up any existing test results
if [ -d "../test-results.xcresult" ]; then
    echo "🧹 Cleaning up existing test results..."
    rm -rf ../test-results.xcresult
fi

# Run tests
echo "📋 Running unit tests..."
xcodebuild test \
    -project RollCall.xcodeproj \
    -scheme RollCall \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    -resultBundlePath ../test-results.xcresult \
    -test-timeouts-enabled YES \
    -default-test-execution-time-allowance 60 \
    | xcpretty --test --color || true

# Check if tests passed
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "✅ All tests passed!"
    
    # Generate coverage report if test bundle exists
    if [ -d "../test-results.xcresult" ]; then
        echo "📊 Generating coverage report..."
        xcrun xccov view --report --json ../test-results.xcresult 2>/dev/null | \
            jq '[.targets[].lineCoverage] | add / length * 100' 2>/dev/null | \
            xargs printf "📈 Test Coverage: %.1f%%\n" || echo "⚠️ Could not calculate coverage"
    fi
else
    echo "❌ Tests failed!"
    exit 1
fi