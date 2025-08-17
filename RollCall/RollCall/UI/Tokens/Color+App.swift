//
// Color+App.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
extension Color {
    // Primary
    static let rcPink500 = Color(hex: "#FF6F9C") // CTAs, active states
    static let rcPink100 = Color(hex: "#FFE5EE") // Light fills, hover
    static let rcPink700 = Color(hex: "#E35680") // Pressed, dark accent

    // Neutrals
    static let rcRice50 = Color(hex: "#FDF9F7") // Background
    static let rcSeaweed800 = Color(hex: "#273238") // Primary text
    static let rcSeaweed900 = Color(hex: "#1B1B1F") // High contrast/dark bg
    static let rcNori800 = Color(hex: "#15242F") // Deep navy accent / strokes
    static let rcRice75 = Color(hex: "#FFF8F9") // Ultra-light panel fill

    // Semantic
    static let rcWasabi400 = Color(hex: "#6B9956") // Success states (WCAG AA compliant)
    static let rcSoy600 = Color(hex: "#6B4F3F") // Secondary text
    static let rcGinger200 = Color(hex: "#FFB3C7") // Info badges
    static let rcSalmon300 = Color(hex: "#E8824A") // Attention/streaks (WCAG AA compliant)

    // Gradient Primitives
    static let rcGradientPink = Color(hex: "#FF477B")
    static let rcGradientOrange = Color(hex: "#E8824A") // WCAG AA compliant

    // Background Gradients
    static let rcBackgroundCenter = Color(hex: "#FDF9F5")
    static let rcBackgroundBase = Color(hex: "#FAF2ED")
    static let rcBackgroundEdge = Color(hex: "#F8E8E0")
    static let rcBottomGradient = Color(hex: "#FFE5EE")
}

// Color from hex initializer
@available(iOS 15.0, macOS 12.0, *)
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let alpha, red, green, blue: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (alpha, red, green, blue) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alpha, red, green, blue) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alpha, red, green, blue) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alpha, red, green, blue) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}
