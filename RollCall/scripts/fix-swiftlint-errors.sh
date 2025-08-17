#!/bin/bash
#
# Fix critical SwiftLint errors
#

set -e

echo "🔧 Fixing SwiftLint Errors"
echo "=========================="
echo ""

# Navigate to project directory
cd "$(dirname "$0")/.."

# Function to remove trailing commas
fix_trailing_commas() {
    echo "📝 Fixing trailing comma violations..."
    
    # Find all Swift files and fix trailing commas in arrays
    find . -name "*.swift" -type f -not -path "./Pods/*" -not -path "./.build/*" | while read -r file; do
        # Fix trailing commas in arrays (],)
        sed -i '' 's/\],$/]/g' "$file"
        
        # Fix trailing commas in arrays with indentation
        sed -i '' 's/^[[:space:]]*\],$/        ]/g' "$file"
        
        # Fix trailing commas before closing bracket on same line
        sed -i '' 's/,\]/]/g' "$file"
        
        # Fix trailing commas in multi-line arrays
        sed -i '' 's/,\([[:space:]]*\)]/\1]/g' "$file"
    done
    
    echo "✅ Trailing commas fixed"
}

# Function to fix opening brace spacing
fix_opening_braces() {
    echo "📝 Fixing opening brace spacing..."
    
    # Fix opening braces that need a space before them
    find . -name "*.swift" -type f -not -path "./Pods/*" -not -path "./.build/*" | while read -r file; do
        # Fix braces without space before them
        sed -i '' 's/\([^[:space:]]\){/\1 {/g' "$file"
        
        # Fix braces on wrong line (this is more complex and might need manual review)
        # For now, just ensure space before brace
    done
    
    echo "✅ Opening brace spacing fixed"
}

# Run fixes
fix_trailing_commas
fix_opening_braces

# Run SwiftFormat to clean up
echo ""
echo "🎨 Running SwiftFormat..."
swiftformat . --quiet

# Show remaining errors
echo ""
echo "📊 Checking remaining errors..."
if swiftlint lint --strict --quiet 2>/dev/null; then
    echo "✅ No critical errors remaining"
else
    echo "⚠️  Some errors may still remain:"
    swiftlint lint --strict 2>&1 | grep "error:" | head -10
fi

echo ""
echo "✨ Done! Run './scripts/validate-quick.sh' to verify."