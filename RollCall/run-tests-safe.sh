#!/bin/bash
# Safe test runner for RollCall with timeouts and single-threaded execution

echo "Running RollCall tests with safety timeouts..."

xcodebuild -project RollCall.xcodeproj \
  -scheme RollCall \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -parallel-testing-enabled NO \
  -maximum-parallel-testing-workers 1 \
  -test-timeouts-enabled YES \
  -default-test-execution-time-allowance 30 \
  test \
  2>&1 | xcpretty --test --color || true

# If tests hang, you can run specific test suites individually:
# xcodebuild ... -only-testing:RollCallTests/ChefTests test
# xcodebuild ... -only-testing:RollCallTests/RestaurantCoreTests test
# etc.

echo "Test run completed (or timed out)"