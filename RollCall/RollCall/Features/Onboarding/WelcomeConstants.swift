//
// WelcomeConstants.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

@available(iOS 15.0, macOS 12.0, *)
enum WelcomeConstants {
    enum Layout {
        static let logoPlateSize: Double = 192
        static let logoImageSize: Double = 144
        static let buttonHeight: Double = 56
        static let buttonCornerRadius: Double = 12
        static let horizontalPadding: Double = 40

        // Spacing (4pt grid)
        static let spacing4: Double = 4
        static let spacing8: Double = 8
        static let spacing12: Double = 12
        static let spacing16: Double = 16
        static let spacing20: Double = 20
        static let spacing24: Double = 24
        static let spacing32: Double = 32
        static let spacing40: Double = 40
        static let spacing56: Double = 56
        static let spacing60: Double = 60
    }

    enum Typography {
        static let titleSize: Double = 64
        static let subtitleSize: Double = 20
        static let taglineSize: Double = 13
        static let taglineKerning: Double = 2.6 // 2% of 13
    }

    enum Animation {
        static let standardDuration: Double = 0.3
        static let rippleDuration: Double = 0.6
        static let pulseDuration: Double = 0.8
        static let titleFadeDuration: Double = 0.15
    }

    enum Shadow {
        static let logoShadowRadius: Double = 8
        static let buttonShadowRadius: Double = 12
        static let shadowOpacity: Double = 0.15
    }

    enum Colors {
        static let backgroundBase = "#FFF4F7"
        static let backgroundCenter = "#FFF0F4"
        static let backgroundEdge = "#FFE5EF"
        static let borderHairline = "#FFD2E2"
        static let bottomGradient = "#FFDCE7"
        static let titlePink = "#FF2E73"
        static let subtitleGray = "#3C3C43"
        static let taglineGray = "#8E8E93"
        static let buttonGradientStart = "#FF477B"
        static let buttonGradientEnd = "#FF9E49"
        static let neumorphicPink = "#FFC1D4"
        static let pageIndicatorInactive = "#D1D1D6"
    }
}
