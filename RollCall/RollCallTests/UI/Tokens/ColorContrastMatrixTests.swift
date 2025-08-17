//
// ColorContrastMatrixTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

@testable import RollCall
import SwiftUI
import XCTest

@available(iOS 15.0, *)
final class ColorContrastMatrixTests: XCTestCase {
    // MARK: - WCAG Requirements

    private let wcagAANormalText: Double = 4.5
    private let wcagAALargeText: Double = 3.0

    // MARK: - Test Case Structure

    private struct ContrastTestCase {
        let foreground: Color
        let background: Color
        let minRatio: Double
        let description: String
    }

    // MARK: - Comprehensive Tests

    func test_allCriticalColorCombinations_meetRequirements() {
        let testCases = self.createCriticalColorTestCases()

        // Test each combination
        for testCase in testCases {
            let ratio = contrastRatio(
                between: testCase.foreground,
                and: testCase.background
            )

            XCTAssertGreaterThanOrEqual(
                ratio,
                testCase.minRatio,
                "\(testCase.description): contrast ratio " +
                    "\(String(format: "%.2f", ratio)) does not meet " +
                    "requirement of \(testCase.minRatio):1"
            )
        }
    }

    private func createCriticalColorTestCases() -> [ContrastTestCase] {
        [
            // Primary text combinations
            ContrastTestCase(
                foreground: .rcSeaweed800,
                background: .rcRice50,
                minRatio: self.wcagAANormalText,
                description: "Primary text on main background"
            ),
            ContrastTestCase(
                foreground: .rcSoy600,
                background: .rcRice50,
                minRatio: self.wcagAANormalText,
                description: "Secondary text on main background"
            ),

            // CTA combinations
            ContrastTestCase(
                foreground: .white,
                background: .rcPink500,
                minRatio: self.wcagAANormalText,
                description: "CTA text on primary button"
            ),
            ContrastTestCase(
                foreground: .rcPink700,
                background: .rcPink100,
                minRatio: self.wcagAANormalText,
                description: "Secondary CTA text"
            ),

            // Status combinations
            ContrastTestCase(
                foreground: .rcWasabi400,
                background: .rcRice50,
                minRatio: self.wcagAANormalText,
                description: "Success text"
            ),
            ContrastTestCase(
                foreground: .rcSalmon300,
                background: .rcRice50,
                minRatio: self.wcagAALargeText,
                description: "Warning text (large only)"
            ),

            // Dark mode combinations
            ContrastTestCase(
                foreground: .rcRice50,
                background: .rcSeaweed900,
                minRatio: self.wcagAANormalText,
                description: "Light text on dark background"
            )
        ]
    }

    func test_interactiveStates_meetContrast() {
        struct InteractiveState {
            let foreground: Color
            let background: Color
            let description: String
        }

        let interactiveStates = [
            InteractiveState(foreground: .rcPink700, background: .rcPink100, description: "Button hover state"),
            InteractiveState(foreground: .rcSeaweed800, background: .rcRice75, description: "Input focus state"),
            InteractiveState(foreground: .rcPink500, background: .rcRice50, description: "Link text"),
            InteractiveState(foreground: .rcNori800, background: .rcRice50, description: "Border on background")
        ]

        for state in interactiveStates {
            let foreground = state.foreground
            let background = state.background
            let description = state.description
            let ratio = contrastRatio(between: foreground, and: background)

            XCTAssertGreaterThanOrEqual(
                ratio,
                self.wcagAANormalText,
                "\(description): contrast ratio \(String(format: "%.2f", ratio)) " +
                    "insufficient for interactive elements"
            )
        }
    }

    func test_semanticColors_againstAllBackgrounds() {
        let semanticColors = [
            ("Success", Color.rcWasabi400),
            ("Info", Color.rcGinger200),
            ("Warning", Color.rcSalmon300),
            ("Error", Color.red)
        ]

        let backgrounds = [
            ("Light", Color.rcRice50),
            ("Ultra Light", Color.rcRice75)
        ]

        for (semanticName, semanticColor) in semanticColors {
            for (bgName, bgColor) in backgrounds {
                let ratio = contrastRatio(between: semanticColor, and: bgColor)
                let description = "\(semanticName) on \(bgName) background"

                // Use large text requirement for colored text
                XCTAssertGreaterThanOrEqual(
                    ratio,
                    self.wcagAALargeText,
                    "\(description): contrast ratio " +
                        "\(String(format: "%.2f", ratio)) below " +
                        "large text requirement"
                )
            }
        }
    }

    func test_debugContrastInfo() {
        // Print contrast ratios for debugging
        printContrastDebugInfo(
            foreground: .rcSeaweed800,
            background: .rcRice50,
            description: "Primary text"
        )

        printContrastDebugInfo(
            foreground: .white,
            background: .rcPink500,
            description: "CTA button"
        )

        printContrastDebugInfo(
            foreground: .rcSoy600,
            background: .rcRice50,
            description: "Secondary text"
        )
    }
}
