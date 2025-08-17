#!/bin/bash
# Script to fix common SwiftLint violations

echo "🔧 Fixing SwiftLint violations..."

# Navigate to RollCall directory
cd "$(dirname "$0")/../RollCall"

# Fix trailing comma violations
echo "📍 Fixing trailing comma violations..."
find . -name "*.swift" -type f | while read -r file; do
    # Remove trailing commas in arrays and dictionaries
    sed -i '' 's/,\([[:space:]]*\]\)/\1/g' "$file"
    sed -i '' 's/,\([[:space:]]*\)\]/\1\]/g' "$file"
done

# Fix opening brace spacing violations
echo "📍 Fixing opening brace spacing violations..."
find . -name "*.swift" -type f | while read -r file; do
    # Fix opening braces that should be on the same line
    sed -i '' '/^[[:space:]]*{$/{N;s/\n[[:space:]]*{/ {/;}' "$file"
done

# Fix non-optional string to data conversion
echo "📍 Fixing non-optional string to data conversions..."
find . -name "*.swift" -type f | while read -r file; do
    # Replace .data(using: .utf8)! with Data(_:)
    sed -i '' 's/"\([^"]*\)"\.data(using: \.utf8)!/Data("\1".utf8)/g' "$file"
done

# Count remaining violations
REMAINING=$(swiftlint --quiet | wc -l | tr -d ' ')
echo "📊 Remaining violations: $REMAINING"

if [ "$REMAINING" -eq 0 ]; then
    echo "✅ All violations fixed!"
else
    echo "⚠️ Some violations require manual fixing:"
    swiftlint --quiet | grep -E 'type_body_length|file_length|identifier_name|function_body_length|large_tuple|for_where|line_length|multiple_closures_with_trailing_closure' | head -20
fi