#!/bin/bash

# Script to integrate RollCallKit into the main RollCall project
set -e

echo "🔧 Integrating RollCallKit into main project..."

# Update WelcomeConstants to use RollCallKit constants
echo "📝 Updating WelcomeConstants to use RollCallKit..."

# Back up original file
cp "RollCall/RollCall/Features/Onboarding/WelcomeConstants.swift" "RollCall/RollCall/Features/Onboarding/WelcomeConstants.swift.backup"

# Update the import and usage
cat > "RollCall/RollCall/Features/Onboarding/WelcomeConstants.swift" << 'EOF'
//
// WelcomeConstants.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/07/25.
//

import Foundation
import RollCallKit

@available(iOS 15.0, macOS 12.0, *)
enum WelcomeConstants {
    enum Layout {
        // Use RollCallKit spacing constants
        static let spacing4 = DesignConstants.Spacing.spacing4
        static let spacing8 = DesignConstants.Spacing.spacing8
        static let spacing12 = DesignConstants.Spacing.spacing12
        static let spacing16 = DesignConstants.Spacing.spacing16
        static let spacing20 = DesignConstants.Spacing.spacing20
        static let spacing24 = DesignConstants.Spacing.spacing24
        static let spacing28 = DesignConstants.Spacing.spacing28
        static let spacing32 = DesignConstants.Spacing.spacing32
        static let spacing40 = DesignConstants.Spacing.spacing40
        static let spacing48 = DesignConstants.Spacing.spacing48
        static let spacing56 = DesignConstants.Spacing.spacing56
        static let spacing64 = DesignConstants.Spacing.spacing64
        static let spacing80 = DesignConstants.Spacing.spacing80
        static let spacing120 = DesignConstants.Spacing.spacing120
        
        // Component-specific sizes
        static let buttonHeight = DesignConstants.ComponentSize.buttonHeight
        static let buttonCornerRadius = DesignConstants.CornerRadius.medium
        static let logoSize = spacing120
    }
    
    enum Colors {
        // Use RollCallKit color tokens
        static let buttonGradientStart = "#FF477B"  // rcGradientPink
        static let buttonGradientEnd = "#FFA56B"    // rcGradientOrange
        
        static let titleColor = "#273238"           // rcSeaweed800
        static let subtitleColor = "#6B4F3F"        // rcSoy600
        static let backgroundColor = "#FDF9F7"      // rcRice50
    }
    
    enum Animation {
        // Use RollCallKit animation constants
        static let logoAnimationDuration = DesignConstants.Animation.mediumDuration
        static let titleAnimationDuration = DesignConstants.Animation.standardDuration
        static let buttonAnimationDuration = DesignConstants.Animation.standardDuration
        static let rippleDuration = DesignConstants.Animation.rippleDuration
        static let springResponse = DesignConstants.Animation.springResponse
        static let springDamping = DesignConstants.Animation.springDamping
    }
    
    enum Shadow {
        // Use RollCallKit shadow constants
        static let shadowOpacity = DesignConstants.Shadow.shadowOpacity
        static let buttonShadowRadius = DesignConstants.Shadow.mediumRadius
        static let logoShadowRadius = DesignConstants.Shadow.largeRadius
    }
}
EOF

echo "✅ WelcomeConstants updated to use RollCallKit"
echo "🎉 RollCallKit integration script completed!"
echo ""
echo "Next steps:"
echo "1. Add RollCallKit as a local package dependency in Xcode"
echo "2. Update imports in UI files to use 'import RollCallKit'"
echo "3. Test the build to ensure everything works"