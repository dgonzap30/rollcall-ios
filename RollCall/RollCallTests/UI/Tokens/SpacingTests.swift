//
// SpacingTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class SpacingTests: XCTestCase {
    // MARK: - 4pt Grid Compliance

    func test_allSpacingValues_followFourPointGrid() {
        let spacings: [CGFloat] = [
            Spacing.xxxSmall,
            Spacing.xxSmall,
            Spacing.xSmall,
            Spacing.small,
            Spacing.medium,
            Spacing.large,
            Spacing.xLarge,
            Spacing.xxLarge,
            Spacing.xxxLarge,
            Spacing.huge,
            Spacing.xHuge,
            Spacing.xxHuge,
            Spacing.xxxHuge,
            Spacing.massive,
            Spacing.xMassive
        ]

        for spacing in spacings {
            XCTAssertTrue(
                Spacing.isOnGrid(spacing),
                "\(spacing) is not on the 4pt grid"
            )
        }
    }

    func test_paddingValues_followFourPointGrid() {
        let paddings: [CGFloat] = [
            Spacing.Padding.tiny,
            Spacing.Padding.small,
            Spacing.Padding.medium,
            Spacing.Padding.large,
            Spacing.Padding.xLarge,
            Spacing.Padding.xxLarge,
            Spacing.Padding.huge
        ]

        for padding in paddings {
            XCTAssertTrue(
                Spacing.isOnGrid(padding),
                "Padding \(padding) is not on the 4pt grid"
            )
        }
    }

    func test_marginValues_followFourPointGrid() {
        let margins: [CGFloat] = [
            Spacing.Margin.small,
            Spacing.Margin.medium,
            Spacing.Margin.large,
            Spacing.Margin.xLarge,
            Spacing.Margin.xxLarge
        ]

        for margin in margins {
            XCTAssertTrue(
                Spacing.isOnGrid(margin),
                "Margin \(margin) is not on the 4pt grid"
            )
        }
    }

    func test_gapValues_followFourPointGrid() {
        let gaps: [CGFloat] = [
            Spacing.Gap.tiny,
            Spacing.Gap.small,
            Spacing.Gap.medium,
            Spacing.Gap.large,
            Spacing.Gap.xLarge,
            Spacing.Gap.xxLarge
        ]

        for gap in gaps {
            XCTAssertTrue(
                Spacing.isOnGrid(gap),
                "Gap \(gap) is not on the 4pt grid"
            )
        }
    }

    // MARK: - Custom Spacing

    func test_customSpacing_calculatesCorrectly() {
        XCTAssertEqual(Spacing.custom(1), 4)
        XCTAssertEqual(Spacing.custom(2), 8)
        XCTAssertEqual(Spacing.custom(3), 12)
        XCTAssertEqual(Spacing.custom(10), 40)
    }

    // MARK: - Grid Detection

    func test_isOnGrid_detectsCorrectly() {
        XCTAssertTrue(Spacing.isOnGrid(0))
        XCTAssertTrue(Spacing.isOnGrid(4))
        XCTAssertTrue(Spacing.isOnGrid(8))
        XCTAssertTrue(Spacing.isOnGrid(100))

        XCTAssertFalse(Spacing.isOnGrid(1))
        XCTAssertFalse(Spacing.isOnGrid(3))
        XCTAssertFalse(Spacing.isOnGrid(5))
        XCTAssertFalse(Spacing.isOnGrid(50.5))
    }

    // MARK: - Value Consistency

    func test_spacingValues_areConsistent() {
        XCTAssertEqual(Spacing.grid, 4)
        XCTAssertEqual(Spacing.xxxSmall, 4)
        XCTAssertEqual(Spacing.xxSmall, 8)
        XCTAssertEqual(Spacing.xSmall, 12)
        XCTAssertEqual(Spacing.small, 16)
        XCTAssertEqual(Spacing.medium, 20)
        XCTAssertEqual(Spacing.large, 24)
        XCTAssertEqual(Spacing.xLarge, 28)
        XCTAssertEqual(Spacing.xxLarge, 32)
        XCTAssertEqual(Spacing.xxxLarge, 36)
        XCTAssertEqual(Spacing.huge, 40)
        XCTAssertEqual(Spacing.xHuge, 44)
        XCTAssertEqual(Spacing.xxHuge, 48)
        XCTAssertEqual(Spacing.xxxHuge, 52)
        XCTAssertEqual(Spacing.massive, 56)
        XCTAssertEqual(Spacing.xMassive, 60)
    }

    func test_spacingValues_areInAscendingOrder() {
        let spacings: [CGFloat] = [
            Spacing.xxxSmall,
            Spacing.xxSmall,
            Spacing.xSmall,
            Spacing.small,
            Spacing.medium,
            Spacing.large,
            Spacing.xLarge,
            Spacing.xxLarge,
            Spacing.xxxLarge,
            Spacing.huge,
            Spacing.xHuge,
            Spacing.xxHuge,
            Spacing.xxxHuge,
            Spacing.massive,
            Spacing.xMassive
        ]

        for index in 1..<spacings.count {
            XCTAssertGreaterThan(
                spacings[index],
                spacings[index - 1],
                "Spacing values are not in ascending order"
            )
        }
    }
}
