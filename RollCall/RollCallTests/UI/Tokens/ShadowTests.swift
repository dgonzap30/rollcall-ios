//
// ShadowTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

@testable import RollCall
import SwiftUI
import XCTest

@available(iOS 15.0, *)
final class ShadowTests: XCTestCase {
    // MARK: - Shadow Style Tests

    func test_shadowStyle_initialization() {
        let shadow = Shadow.Style(color: .black, radius: 10, x: 5, y: 5)

        XCTAssertEqual(shadow.color, Color.black)
        XCTAssertEqual(shadow.radius, 10)
        XCTAssertEqual(shadow.xOffset, 5)
        XCTAssertEqual(shadow.yOffset, 5)
    }

    func test_shadowStyle_defaultOffsets() {
        let shadow = Shadow.Style(color: .black, radius: 10)

        XCTAssertEqual(shadow.xOffset, 0)
        XCTAssertEqual(shadow.yOffset, 0)
    }

    // MARK: - Elevation Shadow Tests

    func test_elevationShadows_haveCorrectProperties() {
        // None
        XCTAssertEqual(Shadow.Elevation.none.radius, 0)
        XCTAssertEqual(Shadow.Elevation.none.xOffset, 0)
        XCTAssertEqual(Shadow.Elevation.none.yOffset, 0)

        // Small
        XCTAssertEqual(Shadow.Elevation.small.radius, 4)
        XCTAssertEqual(Shadow.Elevation.small.yOffset, 2)

        // Medium
        XCTAssertEqual(Shadow.Elevation.medium.radius, 8)
        XCTAssertEqual(Shadow.Elevation.medium.yOffset, 4)

        // Large
        XCTAssertEqual(Shadow.Elevation.large.radius, 16)
        XCTAssertEqual(Shadow.Elevation.large.yOffset, 8)

        // CTA (CD-1: y=3dp, blur=12dp)
        XCTAssertEqual(Shadow.Elevation.cta.radius, 12)
        XCTAssertEqual(Shadow.Elevation.cta.yOffset, 3)

        // Card
        XCTAssertEqual(Shadow.Elevation.card.radius, 24)
        XCTAssertEqual(Shadow.Elevation.card.yOffset, 8)
    }

    func test_elevationShadows_followDesignGuidelines() {
        // D-2: Soft shadows (≤24px blur @ 10% opacity)
        XCTAssertLessThanOrEqual(
            Shadow.Elevation.card.radius,
            24,
            "Card shadow should have ≤24px blur per D-2"
        )
    }

    func test_elevationShadows_increaseWithLevel() {
        // Shadows should get larger with elevation
        XCTAssertLessThan(Shadow.Elevation.none.radius, Shadow.Elevation.small.radius)
        XCTAssertLessThan(Shadow.Elevation.small.radius, Shadow.Elevation.medium.radius)
        XCTAssertLessThan(Shadow.Elevation.medium.radius, Shadow.Elevation.large.radius)
    }

    // MARK: - Neumorphism Tests

    func test_neumorphism_hasCorrectDualShadows() {
        let light = Shadow.Neumorphism.light()

        // Top shadow (light)
        XCTAssertEqual(light.top.radius, 10)
        XCTAssertEqual(light.top.xOffset, -5)
        XCTAssertEqual(light.top.yOffset, -5)

        // Bottom shadow (dark)
        XCTAssertEqual(light.bottom.radius, 10)
        XCTAssertEqual(light.bottom.xOffset, 5)
        XCTAssertEqual(light.bottom.yOffset, 5)

        let medium = Shadow.Neumorphism.medium()

        // Medium should be larger
        XCTAssertGreaterThan(medium.top.radius, light.top.radius)
        XCTAssertGreaterThan(medium.bottom.radius, light.bottom.radius)
    }

    // MARK: - Inner Shadow Tests

    func test_innerShadows_haveCorrectProperties() {
        XCTAssertEqual(Shadow.Inner.subtle.radius, 2)
        XCTAssertEqual(Shadow.Inner.medium.radius, 4)

        // Inner shadows should have no offset by default
        XCTAssertEqual(Shadow.Inner.subtle.xOffset, 0)
        XCTAssertEqual(Shadow.Inner.subtle.yOffset, 0)
        XCTAssertEqual(Shadow.Inner.medium.xOffset, 0)
        XCTAssertEqual(Shadow.Inner.medium.yOffset, 0)
    }

    // MARK: - Shadow Consistency Tests

    func test_allShadows_haveZeroXOffset() {
        // Most shadows should only have Y offset for consistency
        XCTAssertEqual(Shadow.Elevation.none.xOffset, 0)
        XCTAssertEqual(Shadow.Elevation.small.xOffset, 0)
        XCTAssertEqual(Shadow.Elevation.medium.xOffset, 0)
        XCTAssertEqual(Shadow.Elevation.large.xOffset, 0)
        XCTAssertEqual(Shadow.Elevation.cta.xOffset, 0)
        XCTAssertEqual(Shadow.Elevation.card.xOffset, 0)
    }
}
