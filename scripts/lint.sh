#!/bin/bash
# Lint script for RollCall
set -e

echo "🔍 Running code quality checks..."

# Navigate to project root
cd "$(dirname "$0")/.."

# Run SwiftFormat in lint mode
echo "🎨 Checking code formatting..."
if ! swiftformat . --lint --quiet; then
    echo "❌ Code formatting issues found. Run 'swiftformat .' to fix."
    exit 1
fi

# Run SwiftLint
echo "🧪 Running SwiftLint..."
if ! swiftlint --quiet; then
    echo "❌ SwiftLint violations found."
    exit 1
fi

echo "✅ All code quality checks passed!"