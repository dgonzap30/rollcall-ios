//
// ColorContrastAlphaTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

@testable import RollCall
import SwiftUI
import XCTest

@available(iOS 15.0, *)
final class ColorContrastAlphaTests: XCTestCase {
    // MARK: - WCAG Requirements

    private let wcagAANormalText: Double = 4.5
    private let wcagAALargeText: Double = 3.0

    // MARK: - Alpha Blending Tests

    func test_semiTransparentOverlays_maintainReadability() {
        let textColor = Color.rcSeaweed800
        let backgroundColor = Color.rcRice50

        // Test various overlay transparencies
        let overlayTransparencies: [Double] = [0.1, 0.2, 0.3, 0.4, 0.5]

        for transparency in overlayTransparencies {
            let overlay = Color.rcPink500.opacity(transparency)
            let blendedBackground = blendWithBackground(overlay, over: backgroundColor)
            let ratio = contrastRatio(between: textColor, and: blendedBackground)

            XCTAssertGreaterThanOrEqual(
                ratio,
                self.wcagAANormalText,
                "Text readability compromised with \(Int(transparency * 100))% overlay"
            )
        }
    }

    func test_modalOverlays_preserveTextContrast() {
        let textColor = Color.rcSeaweed800
        let backgroundColor = Color.rcRice50

        // Modal overlay with 80% opacity
        let modalOverlay = Color.black.opacity(0.8)
        let blendedBackground = blendWithBackground(modalOverlay, over: backgroundColor)
        let ratio = contrastRatio(between: Color.white, and: blendedBackground)

        XCTAssertGreaterThanOrEqual(
            ratio,
            self.wcagAANormalText,
            "Modal overlay text contrast insufficient"
        )
    }

    func test_hoverStates_maintainContrast() {
        // Button hover state
        let baseButton = Color.rcPink500
        let hoverOverlay = Color.white.opacity(0.1)
        let hoverState = blendWithBackground(hoverOverlay, over: baseButton)

        let ratio = contrastRatio(between: Color.white, and: hoverState)

        XCTAssertGreaterThanOrEqual(
            ratio,
            self.wcagAANormalText,
            "Button hover state contrast insufficient"
        )
    }

    func test_successStates_withTransparency() {
        let successBackground = Color.rcWasabi400.opacity(0.1)
        let blendedBackground = blendWithBackground(successBackground, over: Color.rcRice50)
        let ratio = contrastRatio(between: Color.rcSeaweed800, and: blendedBackground)

        XCTAssertGreaterThanOrEqual(
            ratio,
            self.wcagAANormalText,
            "Success state transparency affects text readability"
        )
    }

    func test_errorStates_withTransparency() {
        let errorBackground = Color.rcSalmon300.opacity(0.15)
        let blendedBackground = blendWithBackground(errorBackground, over: Color.rcRice50)
        let ratio = contrastRatio(between: Color.rcSeaweed800, and: blendedBackground)

        XCTAssertGreaterThanOrEqual(
            ratio,
            self.wcagAANormalText,
            "Error state transparency affects text readability"
        )
    }

    func test_loadingStates_maintainVisibility() {
        // Loading overlay scenarios
        let loadingOverlay = Color.rcRice50.opacity(0.9)
        let blendedBackground = blendWithBackground(loadingOverlay, over: Color.rcSeaweed800)

        // Loading spinner should be visible
        let spinnerRatio = contrastRatio(between: Color.rcPink500, and: blendedBackground)

        XCTAssertGreaterThanOrEqual(
            spinnerRatio,
            self.wcagAALargeText,
            "Loading spinner not sufficiently visible"
        )
    }
}
