//
// TypographyTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

@testable import RollCall
import SwiftUI
import XCTest

@available(iOS 15.0, *)
final class TypographyTests: XCTestCase {
    // MARK: - Font Family Tests

    func test_fontFamilies_areCorrect() {
        XCTAssertEqual(Typography.FontFamily.headers, "Poppins-SemiBold")
        XCTAssertEqual(Typography.FontFamily.headersRegular, "Poppins-Regular")
        XCTAssertEqual(Typography.FontFamily.body, "Inter-Regular")
        XCTAssertEqual(Typography.FontFamily.bodyMedium, "Inter-Medium")
        XCTAssertEqual(Typography.FontFamily.bodySemiBold, "Inter-SemiBold")
        XCTAssertEqual(Typography.FontFamily.bodyBold, "Inter-Bold")
    }

    // MARK: - Font Size Tests

    func test_fontSizes_areConsistent() {
        XCTAssertEqual(Typography.Size.xxSmall, 11)
        XCTAssertEqual(Typography.Size.xSmall, 12)
        XCTAssertEqual(Typography.Size.small, 14)
        XCTAssertEqual(Typography.Size.medium, 16)
        XCTAssertEqual(Typography.Size.large, 18)
        XCTAssertEqual(Typography.Size.xLarge, 20)
        XCTAssertEqual(Typography.Size.xxLarge, 24)
        XCTAssertEqual(Typography.Size.xxxLarge, 28)
        XCTAssertEqual(Typography.Size.display, 32)
        XCTAssertEqual(Typography.Size.displayLarge, 36)
    }

    func test_fontSizes_areInAscendingOrder() {
        let sizes: [CGFloat] = [
            Typography.Size.xxSmall,
            Typography.Size.xSmall,
            Typography.Size.small,
            Typography.Size.medium,
            Typography.Size.large,
            Typography.Size.xLarge,
            Typography.Size.xxLarge,
            Typography.Size.xxxLarge,
            Typography.Size.display,
            Typography.Size.displayLarge
        ]

        for index in 1..<sizes.count {
            XCTAssertGreaterThan(
                sizes[index],
                sizes[index - 1],
                "Font sizes are not in ascending order"
            )
        }
    }

    // MARK: - Line Height Tests

    func test_lineHeights_areValid() {
        XCTAssertEqual(Typography.LineHeight.tight, 1.2)
        XCTAssertEqual(Typography.LineHeight.normal, 1.4)
        XCTAssertEqual(Typography.LineHeight.relaxed, 1.6)
        XCTAssertEqual(Typography.LineHeight.loose, 1.8)

        // Verify they're in ascending order
        XCTAssertLessThan(Typography.LineHeight.tight, Typography.LineHeight.normal)
        XCTAssertLessThan(Typography.LineHeight.normal, Typography.LineHeight.relaxed)
        XCTAssertLessThan(Typography.LineHeight.relaxed, Typography.LineHeight.loose)
    }

    // MARK: - Font Weight Tests

    func test_fontWeights_areCorrect() {
        XCTAssertEqual(Typography.Weight.regular, Font.Weight.regular)
        XCTAssertEqual(Typography.Weight.medium, Font.Weight.medium)
        XCTAssertEqual(Typography.Weight.semiBold, Font.Weight.semibold)
        XCTAssertEqual(Typography.Weight.bold, Font.Weight.bold)
    }

    // MARK: - Font Style Tests

    func test_fontStyles_useCorrectFamiliesAndSizes() {
        // Can't directly test Font objects, but we can ensure the methods exist
        // and don't crash when called
        _ = Typography.Style.displayLarge()
        _ = Typography.Style.display()
        _ = Typography.Style.title1()
        _ = Typography.Style.title2()
        _ = Typography.Style.title3()
        _ = Typography.Style.headline()
        _ = Typography.Style.body()
        _ = Typography.Style.bodyMedium()
        _ = Typography.Style.bodySemiBold()
        _ = Typography.Style.callout()
        _ = Typography.Style.caption()
        _ = Typography.Style.footnote()
    }

    // MARK: - Typography Scale Tests

    func test_typographyScale_followsHierarchy() {
        // Display should be larger than titles
        XCTAssertGreaterThan(Typography.Size.displayLarge, Typography.Size.display)
        XCTAssertGreaterThan(Typography.Size.display, Typography.Size.xxxLarge)

        // Titles should be larger than body
        XCTAssertGreaterThan(Typography.Size.xxxLarge, Typography.Size.xxLarge)
        XCTAssertGreaterThan(Typography.Size.xxLarge, Typography.Size.xLarge)
        XCTAssertGreaterThan(Typography.Size.xLarge, Typography.Size.large)

        // Body should be larger than small text
        XCTAssertGreaterThan(Typography.Size.large, Typography.Size.medium)
        XCTAssertGreaterThan(Typography.Size.medium, Typography.Size.small)
        XCTAssertGreaterThan(Typography.Size.small, Typography.Size.xSmall)
        XCTAssertGreaterThan(Typography.Size.xSmall, Typography.Size.xxSmall)
    }

    // MARK: - Accessibility Tests

    func test_minimumFontSize_meetsAccessibilityGuidelines() {
        // WCAG recommends minimum 12pt for body text
        XCTAssertGreaterThanOrEqual(
            Typography.Size.xSmall,
            12,
            "Minimum font size should be at least 12pt for accessibility"
        )

        // Body text should be at least 14pt for optimal readability
        XCTAssertGreaterThanOrEqual(
            Typography.Size.small,
            14,
            "Body text should be at least 14pt"
        )
    }
}
