//
// ColorContrastBasicTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

@testable import RollCall
import SwiftUI
import XCTest

@available(iOS 15.0, *)
final class ColorContrastBasicTests: XCTestCase {
    // MARK: - WCAG Requirements

    private let wcagAANormalText: Double = 4.5
    private let wcagAALargeText: Double = 3.0
    private let wcagAAA: Double = 7.0

    // MARK: - Basic Contrast Tests

    func test_primaryTextOnBackground_meetsWCAGAA() {
        let textColor = Color.rcSeaweed800
        let backgroundColor = Color.rcRice50

        let ratio = contrastRatio(between: textColor, and: backgroundColor)

        XCTAssertGreaterThanOrEqual(
            ratio,
            self.wcagAANormalText,
            "Primary text contrast ratio \(String(format: "%.2f", ratio)) " +
                "does not meet WCAG AA requirement of \(self.wcagAANormalText):1"
        )
    }

    func test_secondaryTextOnBackground_meetsWCAGAA() {
        let textColor = Color.rcSoy600
        let backgroundColor = Color.rcRice50

        let ratio = contrastRatio(between: textColor, and: backgroundColor)

        XCTAssertGreaterThanOrEqual(
            ratio,
            self.wcagAANormalText,
            "Secondary text contrast ratio \(String(format: "%.2f", ratio)) " +
                "does not meet WCAG AA requirement of \(self.wcagAANormalText):1"
        )
    }

    func test_accentTextOnBackground_meetsWCAGAA() {
        let textColor = Color.rcNori800
        let backgroundColor = Color.rcRice50

        let ratio = contrastRatio(between: textColor, and: backgroundColor)

        XCTAssertGreaterThanOrEqual(
            ratio,
            self.wcagAANormalText,
            "Accent text contrast ratio \(String(format: "%.2f", ratio)) " +
                "does not meet WCAG AA requirement of \(self.wcagAANormalText):1"
        )
    }

    func test_primaryCTAText_meetsWCAGAA() {
        let textColor = Color.white
        let backgroundColor = Color.rcPink500

        let ratio = contrastRatio(between: textColor, and: backgroundColor)

        XCTAssertGreaterThanOrEqual(
            ratio,
            self.wcagAANormalText,
            "Primary CTA text contrast ratio \(String(format: "%.2f", ratio)) " +
                "does not meet WCAG AA requirement of \(self.wcagAANormalText):1"
        )
    }

    func test_successTextOnBackground_meetsWCAGAA() {
        let textColor = Color.rcWasabi400
        let backgroundColor = Color.rcRice50

        let ratio = contrastRatio(between: textColor, and: backgroundColor)

        XCTAssertGreaterThanOrEqual(
            ratio,
            self.wcagAANormalText,
            "Success text contrast ratio \(String(format: "%.2f", ratio)) " +
                "does not meet WCAG AA requirement of \(self.wcagAANormalText):1"
        )
    }

    func test_errorTextOnBackground_meetsWCAGAA() {
        let textColor = Color.rcSalmon300
        let backgroundColor = Color.rcRice50

        let ratio = contrastRatio(between: textColor, and: backgroundColor)

        XCTAssertGreaterThanOrEqual(
            ratio,
            self.wcagAANormalText,
            "Error text contrast ratio \(String(format: "%.2f", ratio)) " +
                "does not meet WCAG AA requirement of \(self.wcagAANormalText):1"
        )
    }

    func test_infoTextOnBackground_meetsWCAGAA() {
        let textColor = Color.rcGinger200
        let backgroundColor = Color.rcRice50

        let ratio = contrastRatio(between: textColor, and: backgroundColor)

        XCTAssertGreaterThanOrEqual(
            ratio,
            self.wcagAALargeText,
            "Info text contrast ratio \(String(format: "%.2f", ratio)) " +
                "does not meet WCAG AA large text requirement of \(self.wcagAALargeText):1"
        )
    }
}
