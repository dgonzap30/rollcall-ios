//
// ColorTestUtilities.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import SwiftUI
import XCTest

// MARK: - Color Components Structures

@available(iOS 15.0, *)
struct ColorComponents {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
}

@available(iOS 15.0, *)
struct RGBComponents {
    let red: Double
    let green: Double
    let blue: Double
}

// MARK: - Contrast Ratio Calculation

@available(iOS 15.0, *)
func contrastRatio(between color1: Color, and color2: Color) -> Double {
    let luminance1 = relativeLuminance(of: color1)
    let luminance2 = relativeLuminance(of: color2)

    let lighter = max(luminance1, luminance2)
    let darker = min(luminance1, luminance2)

    return (lighter + 0.05) / (darker + 0.05)
}

@available(iOS 15.0, *)
func relativeLuminance(of color: Color) -> Double {
    let components = color.rgbaComponents()

    let sRed = gammaCorrect(components.red)
    let sGreen = gammaCorrect(components.green)
    let sBlue = gammaCorrect(components.blue)

    return 0.2126 * sRed + 0.7152 * sGreen + 0.0722 * sBlue
}

@available(iOS 15.0, *)
func gammaCorrect(_ component: Double) -> Double {
    if component <= 0.03928 {
        component / 12.92
    } else {
        pow((component + 0.055) / 1.055, 2.4)
    }
}

// MARK: - Alpha Blending

@available(iOS 15.0, *)
func blendWithBackground(_ foreground: Color, over background: Color) -> Color {
    let fgComponents = foreground.rgbaComponents()
    let bgComponents = background.rgbaComponents()

    let alpha = fgComponents.alpha
    let inverseAlpha = 1.0 - alpha

    let red = fgComponents.red * alpha + bgComponents.red * inverseAlpha
    let green = fgComponents.green * alpha + bgComponents.green * inverseAlpha
    let blue = fgComponents.blue * alpha + bgComponents.blue * inverseAlpha

    return Color(.sRGB, red: red, green: green, blue: blue, opacity: 1.0)
}

// MARK: - Color Extension for RGBA Components

@available(iOS 15.0, *)
extension Color {
    func rgbaComponents() -> ColorComponents {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return ColorComponents(
            red: Double(red),
            green: Double(green),
            blue: Double(blue),
            alpha: Double(alpha)
        )
    }
}

// MARK: - Test Helpers

@available(iOS 15.0, *)
func printContrastDebugInfo(
    foreground: Color,
    background: Color,
    description: String
) {
    let ratio = contrastRatio(between: foreground, and: background)
    print("\(description): \(String(format: "%.2f", ratio)):1")
}
