#!/bin/bash

# Test each test class individually to find which one hangs

echo "Testing MainTabViewModelTests..."
if timeout 30 xcodebuild -project RollCall.xcodeproj -scheme RollCall test \
    -only-testing:RollCallTests/MainTabViewModelTests \
    -destination 'platform=iOS Simulator,name=iPhone 16' > /dev/null 2>&1; then
    echo "✅ MainTabViewModelTests passed"
else
    echo "❌ MainTabViewModelTests failed or timed out"
fi

echo "Testing AppCoordinatorTests..."
if timeout 30 xcodebuild -project RollCall.xcodeproj -scheme RollCall test \
    -only-testing:RollCallTests/AppCoordinatorTests \
    -destination 'platform=iOS Simulator,name=iPhone 16' > /dev/null 2>&1; then
    echo "✅ AppCoordinatorTests passed"
else
    echo "❌ AppCoordinatorTests failed or timed out"
fi

echo "Testing individual methods in AppCoordinatorTests..."
test_methods=(
    "test_appCoordinator_isSingleton"
    "test_start_whenNotOnboarded_returnsOnboardingView"
    "test_start_whenOnboarded_returnsMainView"
    "test_onboardingCoordinatorDidFinish_updatesStateAndTransitionsToMain"
    "test_createMainView_createsMainTabCoordinator"
    "test_mainTabCoordinatorDidRequestReset_resetsOnboardingState"
    "test_mainTabCoordinatorDidRequestReset_cleansUpMainTabCoordinator"
    "test_technicalDebtDocumentation_exists"
    "test_appCoordinator_handlesConcurrentAccess"
)

for method in "${test_methods[@]}"; do
    echo "Testing $method..."
    if timeout 10 xcodebuild -project RollCall.xcodeproj -scheme RollCall test \
        -only-testing:RollCallTests/AppCoordinatorTests/$method \
        -destination 'platform=iOS Simulator,name=iPhone 16' > /dev/null 2>&1; then
        echo "  ✅ passed"
    else
        echo "  ❌ failed or timed out"
    fi
done