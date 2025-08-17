#!/bin/bash
# Build script for RollCall
set -e

echo "🏗️  Building RollCall..."

# Navigate to RollCall directory
cd "$(dirname "$0")/../RollCall"

# Clean build artifacts
echo "🧹 Cleaning build artifacts..."
if [ -d ".build" ]; then
    rm -rf .build
fi

# Run SwiftFormat
echo "🎨 Running SwiftFormat..."
swiftformat . --quiet

# Run SwiftLint
echo "🧪 Running SwiftLint..."
swiftlint --quiet --strict

# Build for iOS
echo "📱 Building for iOS..."
xcodebuild build \
    -project RollCall.xcodeproj \
    -scheme RollCall \
    -destination 'platform=iOS Simulator,name=iPhone 15' \
    -quiet

echo "✅ Build completed successfully!"