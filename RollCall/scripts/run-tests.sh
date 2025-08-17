#!/bin/bash

# RollCall Test Runner Script
# Manages simulator lifecycle and runs tests with proper timeout handling
# Produces xcresult file for coverage extraction

set -e

# Configuration
PROJECT_PATH="RollCall.xcodeproj"
SCHEME="RollCall"
SIMULATOR_NAME="iPhone 16"
SIMULATOR_OS="iOS"
RESULT_BUNDLE_PATH="test-results.xcresult"
TIMEOUT_SECONDS=300  # 5 minutes

echo "🚀 RollCall Test Runner"
echo "========================"

# Function to cleanup on exit
cleanup() {
    echo "🧹 Cleaning up..."
    
    # Shutdown simulator if running
    if [ -n "$SIMULATOR_ID" ]; then
        echo "   Shutting down simulator..."
        xcrun simctl shutdown "$SIMULATOR_ID" 2>/dev/null || true
    fi
    
    echo "✅ Cleanup complete"
}

# Set trap for cleanup on exit
trap cleanup EXIT

# Find or create simulator
echo "📱 Setting up simulator..."
SIMULATOR_ID=$(xcrun simctl list devices | grep "$SIMULATOR_NAME" | grep -v unavailable | head -1 | grep -oE '[A-F0-9]{8}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{4}-[A-F0-9]{12}' || true)

if [ -z "$SIMULATOR_ID" ]; then
    echo "   Creating new simulator: $SIMULATOR_NAME"
    DEVICE_TYPE=$(xcrun simctl list devicetypes | grep "$SIMULATOR_NAME" | head -1 | awk -F'(' '{print $2}' | awk -F')' '{print $1}')
    RUNTIME=$(xcrun simctl list runtimes | grep "$SIMULATOR_OS" | tail -1 | awk -F'(' '{print $2}' | awk -F')' '{print $1}')
    
    if [ -z "$DEVICE_TYPE" ] || [ -z "$RUNTIME" ]; then
        echo "❌ Failed to find device type or runtime"
        echo "   Available device types:"
        xcrun simctl list devicetypes | grep iPhone
        echo "   Available runtimes:"
        xcrun simctl list runtimes | grep iOS
        exit 1
    fi
    
    SIMULATOR_ID=$(xcrun simctl create "$SIMULATOR_NAME" "$DEVICE_TYPE" "$RUNTIME")
    echo "   Created simulator: $SIMULATOR_ID"
else
    echo "   Found existing simulator: $SIMULATOR_ID"
fi

# Boot simulator if not already booted
SIMULATOR_STATE=$(xcrun simctl list devices | grep "$SIMULATOR_ID" | grep -oE '\((Booted|Shutdown)\)' | tr -d '()')

if [ "$SIMULATOR_STATE" != "Booted" ]; then
    echo "   Booting simulator..."
    xcrun simctl boot "$SIMULATOR_ID"
    
    # Wait for simulator to boot
    MAX_WAIT=30
    WAITED=0
    while [ "$WAITED" -lt "$MAX_WAIT" ]; do
        if xcrun simctl list devices | grep "$SIMULATOR_ID" | grep -q "Booted"; then
            echo "   Simulator booted successfully"
            break
        fi
        sleep 1
        WAITED=$((WAITED + 1))
    done
    
    if [ "$WAITED" -eq "$MAX_WAIT" ]; then
        echo "⚠️  Simulator boot timeout, continuing anyway..."
    fi
else
    echo "   Simulator already booted"
fi

# Clean previous results
if [ -f "$RESULT_BUNDLE_PATH" ]; then
    echo "🗑️  Removing previous test results..."
    rm -rf "$RESULT_BUNDLE_PATH"
fi

# Run tests with timeout
echo "🧪 Running tests..."
echo "   Project: $PROJECT_PATH"
echo "   Scheme: $SCHEME"
echo "   Simulator: $SIMULATOR_NAME ($SIMULATOR_ID)"
echo "   Timeout: ${TIMEOUT_SECONDS}s"

# Use timeout command if available, otherwise use background process
if command -v timeout >/dev/null 2>&1; then
    # GNU coreutils timeout
    timeout "$TIMEOUT_SECONDS" xcodebuild test \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -destination "id=$SIMULATOR_ID" \
        -resultBundlePath "$RESULT_BUNDLE_PATH" \
        -test-timeouts-enabled YES \
        -maximum-test-execution-time-allowance 60 \
        2>&1 | xcpretty --test --color || TEST_EXIT_CODE=$?
elif command -v gtimeout >/dev/null 2>&1; then
    # macOS with GNU coreutils installed via Homebrew
    gtimeout "$TIMEOUT_SECONDS" xcodebuild test \
        -project "$PROJECT_PATH" \
        -scheme "$SCHEME" \
        -destination "id=$SIMULATOR_ID" \
        -resultBundlePath "$RESULT_BUNDLE_PATH" \
        -test-timeouts-enabled YES \
        -maximum-test-execution-time-allowance 60 \
        2>&1 | xcpretty --test --color || TEST_EXIT_CODE=$?
else
    # Fallback: Run in background with manual timeout
    (
        xcodebuild test \
            -project "$PROJECT_PATH" \
            -scheme "$SCHEME" \
            -destination "id=$SIMULATOR_ID" \
            -resultBundlePath "$RESULT_BUNDLE_PATH" \
            -test-timeouts-enabled YES \
            -maximum-test-execution-time-allowance 60 \
            2>&1 | xcpretty --test --color
    ) &
    TEST_PID=$!
    
    # Wait for tests or timeout
    SECONDS_WAITED=0
    while [ "$SECONDS_WAITED" -lt "$TIMEOUT_SECONDS" ]; do
        if ! kill -0 "$TEST_PID" 2>/dev/null; then
            # Process finished
            wait "$TEST_PID"
            TEST_EXIT_CODE=$?
            break
        fi
        sleep 1
        SECONDS_WAITED=$((SECONDS_WAITED + 1))
    done
    
    # Kill if still running
    if kill -0 "$TEST_PID" 2>/dev/null; then
        echo "⏱️  Test timeout reached, terminating..."
        kill -TERM "$TEST_PID" 2>/dev/null || true
        sleep 2
        kill -KILL "$TEST_PID" 2>/dev/null || true
        TEST_EXIT_CODE=124  # Standard timeout exit code
    fi
fi

# Check test results
if [ -d "$RESULT_BUNDLE_PATH" ]; then
    echo "📊 Test results saved to: $RESULT_BUNDLE_PATH"
    
    # Extract basic test summary
    if command -v xcrun xccov >/dev/null 2>&1; then
        echo ""
        echo "📈 Coverage Summary:"
        xcrun xccov view --report --only-targets "$RESULT_BUNDLE_PATH" 2>/dev/null | head -20 || true
    fi
else
    echo "⚠️  No test results bundle created"
fi

# Determine exit status
if [ -z "$TEST_EXIT_CODE" ]; then
    TEST_EXIT_CODE=0
fi

if [ "$TEST_EXIT_CODE" -eq 0 ]; then
    echo ""
    echo "✅ Tests completed successfully!"
elif [ "$TEST_EXIT_CODE" -eq 124 ]; then
    echo ""
    echo "⏱️  Tests timed out after ${TIMEOUT_SECONDS}s"
    exit 1
else
    echo ""
    echo "❌ Tests failed with exit code: $TEST_EXIT_CODE"
    exit "$TEST_EXIT_CODE"
fi