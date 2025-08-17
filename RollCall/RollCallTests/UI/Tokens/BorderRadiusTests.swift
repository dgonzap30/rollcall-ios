//
// BorderRadiusTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class BorderRadiusTests: XCTestCase {
    // MARK: - Border Radius Value Tests

    func test_borderRadiusValues_areConsistent() {
        XCTAssertEqual(BorderRadius.none, 0)
        XCTAssertEqual(BorderRadius.xSmall, 4)
        XCTAssertEqual(BorderRadius.small, 8)
        XCTAssertEqual(BorderRadius.medium, 12)
        XCTAssertEqual(BorderRadius.large, 16)
        XCTAssertEqual(BorderRadius.xLarge, 20)
        XCTAssertEqual(BorderRadius.xxLarge, 24)
        XCTAssertEqual(BorderRadius.full, 9999)
    }

    func test_borderRadiusValues_followFourPointGrid() {
        let radii: [CGFloat] = [
            BorderRadius.none,
            BorderRadius.xSmall,
            BorderRadius.small,
            BorderRadius.medium,
            BorderRadius.large,
            BorderRadius.xLarge,
            BorderRadius.xxLarge
        ]

        for radius in radii where radius != BorderRadius.full { // Full is intentionally off-grid
            XCTAssertEqual(
                radius.truncatingRemainder(dividingBy: 4),
                0,
                "Border radius \(radius) is not on 4pt grid"
            )
        }
    }

    func test_borderRadiusValues_areInAscendingOrder() {
        let radii: [CGFloat] = [
            BorderRadius.none,
            BorderRadius.xSmall,
            BorderRadius.small,
            BorderRadius.medium,
            BorderRadius.large,
            BorderRadius.xLarge,
            BorderRadius.xxLarge
        ]

        for index in 1..<radii.count {
            XCTAssertGreaterThan(
                radii[index],
                radii[index - 1],
                "Border radius values are not in ascending order"
            )
        }
    }

    // MARK: - Component Radius Tests

    func test_componentRadiusValues_areConsistent() {
        XCTAssertEqual(BorderRadius.Component.badge, 4)
        XCTAssertEqual(BorderRadius.Component.button, 12)
        XCTAssertEqual(BorderRadius.Component.textField, 12)
        XCTAssertEqual(BorderRadius.Component.card, 16)
        XCTAssertEqual(BorderRadius.Component.modal, 20)
        XCTAssertEqual(BorderRadius.Component.container, 24)
    }

    func test_componentRadiusValues_matchBaseValues() {
        XCTAssertEqual(BorderRadius.Component.badge, BorderRadius.xSmall)
        XCTAssertEqual(BorderRadius.Component.button, BorderRadius.medium)
        XCTAssertEqual(BorderRadius.Component.textField, BorderRadius.medium)
        XCTAssertEqual(BorderRadius.Component.card, BorderRadius.large)
        XCTAssertEqual(BorderRadius.Component.modal, BorderRadius.xLarge)
        XCTAssertEqual(BorderRadius.Component.container, BorderRadius.xxLarge)
    }

    // MARK: - Design Guideline Tests

    func test_borderRadius_followsDesignGuidelines() {
        // D-2: Use rounded corners (12-16px radius)
        XCTAssertGreaterThanOrEqual(
            BorderRadius.medium,
            12,
            "Medium radius should be at least 12px per D-2"
        )
        XCTAssertLessThanOrEqual(
            BorderRadius.large,
            16,
            "Large radius should be at most 16px per D-2"
        )
    }

    // MARK: - RCRectCorner Tests

    func test_rcRectCorner_optionSet() {
        let topLeft = RCRectCorner.topLeft
        let topRight = RCRectCorner.topRight
        let bottomLeft = RCRectCorner.bottomLeft
        let bottomRight = RCRectCorner.bottomRight

        // Test individual corners
        XCTAssertEqual(topLeft.rawValue, 1)
        XCTAssertEqual(topRight.rawValue, 2)
        XCTAssertEqual(bottomLeft.rawValue, 4)
        XCTAssertEqual(bottomRight.rawValue, 8)

        // Test combinations
        let top = RCRectCorner.top
        XCTAssertTrue(top.contains(.topLeft))
        XCTAssertTrue(top.contains(.topRight))
        XCTAssertFalse(top.contains(.bottomLeft))
        XCTAssertFalse(top.contains(.bottomRight))

        let all = RCRectCorner.all
        XCTAssertTrue(all.contains(.topLeft))
        XCTAssertTrue(all.contains(.topRight))
        XCTAssertTrue(all.contains(.bottomLeft))
        XCTAssertTrue(all.contains(.bottomRight))
    }
}
