#!/bin/bash

# This script runs SwiftLint outside of Xcode's sandbox
# It's called from the Xcode build phase

export PATH="$PATH:/opt/homebrew/bin"

if command -v swiftlint >/dev/null 2>&1; then
    cd "${SRCROOT}/RollCall"
    swiftlint
else
    echo "warning: SwiftLint not installed, download from https://github.com/realm/SwiftLint"
fi