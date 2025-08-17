//
// AnimationTokensTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

@testable import RollCall
import SwiftUI
import XCTest

@available(iOS 15.0, *)
final class AnimationTokensTests: XCTestCase {
    // MARK: - Duration Tests

    func test_animationDurations_areConsistent() {
        XCTAssertEqual(AnimationTokens.Duration.instant, 0.1)
        XCTAssertEqual(AnimationTokens.Duration.fast, 0.15)
        XCTAssertEqual(AnimationTokens.Duration.standard, 0.2)
        XCTAssertEqual(AnimationTokens.Duration.medium, 0.3)
        XCTAssertEqual(AnimationTokens.Duration.slow, 0.4)
        XCTAssertEqual(AnimationTokens.Duration.celebratory, 0.4)
        XCTAssertEqual(AnimationTokens.Duration.xSlow, 0.6)
    }

    func test_animationDurations_areInAscendingOrder() {
        let durations: [Double] = [
            AnimationTokens.Duration.instant,
            AnimationTokens.Duration.fast,
            AnimationTokens.Duration.standard,
            AnimationTokens.Duration.medium,
            AnimationTokens.Duration.slow,
            AnimationTokens.Duration.xSlow
        ]

        for index in 1..<durations.count {
            XCTAssertGreaterThan(
                durations[index],
                durations[index - 1],
                "Animation durations are not in ascending order"
            )
        }
    }

    func test_standardDuration_followsDesignGuideline() {
        // MH-1: Standard transitions should be 200ms
        XCTAssertEqual(
            AnimationTokens.Duration.standard,
            0.2,
            "Standard duration should be 200ms per MH-1 guideline"
        )
    }

    func test_celebratoryDuration_matchesSlow() {
        // Celebratory animations should use the same duration as slow
        XCTAssertEqual(
            AnimationTokens.Duration.celebratory,
            AnimationTokens.Duration.slow,
            "Celebratory duration should match slow duration"
        )
    }

    // MARK: - Curve Tests

    func test_animationCurves_useStandardDuration() {
        // Can't directly test Animation objects, but ensure they don't crash
        _ = AnimationTokens.Curve.easeInOut
        _ = AnimationTokens.Curve.easeIn
        _ = AnimationTokens.Curve.easeOut
        _ = AnimationTokens.Curve.linear
        _ = AnimationTokens.Curve.standard()
        _ = AnimationTokens.Curve.standardSlow()
    }

    // MARK: - Spring Animation Tests

    func test_springAnimations_exist() {
        // Ensure spring animations can be created without crashing
        _ = AnimationTokens.Spring.standard()
        _ = AnimationTokens.Spring.bouncy()
        _ = AnimationTokens.Spring.gentle()
        _ = AnimationTokens.Spring.celebratory()
    }

    // MARK: - Delay Tests

    func test_animationDelays_areConsistent() {
        XCTAssertEqual(AnimationTokens.Delay.none, 0)
        XCTAssertEqual(AnimationTokens.Delay.short, 0.05)
        XCTAssertEqual(AnimationTokens.Delay.medium, 0.1)
        XCTAssertEqual(AnimationTokens.Delay.long, 0.2)
        XCTAssertEqual(AnimationTokens.Delay.xLong, 0.3)
    }

    func test_animationDelays_areInAscendingOrder() {
        let delays: [Double] = [
            AnimationTokens.Delay.none,
            AnimationTokens.Delay.short,
            AnimationTokens.Delay.medium,
            AnimationTokens.Delay.long,
            AnimationTokens.Delay.xLong
        ]

        for index in 1..<delays.count {
            XCTAssertGreaterThan(
                delays[index],
                delays[index - 1],
                "Animation delays are not in ascending order"
            )
        }
    }

    // MARK: - Performance Tests

    func test_animationDurations_areReasonable() {
        // Animations should be perceivable but not too slow
        XCTAssertGreaterThanOrEqual(
            AnimationTokens.Duration.instant,
            0.1,
            "Instant animations should be at least 100ms to be perceivable"
        )

        XCTAssertLessThanOrEqual(
            AnimationTokens.Duration.xSlow,
            1.0,
            "Even slow animations should complete within 1 second"
        )
    }

    // MARK: - Consistency Tests

    func test_delayValues_alignWithDurations() {
        // Long delay should match standard duration
        XCTAssertEqual(
            AnimationTokens.Delay.long,
            AnimationTokens.Duration.standard,
            "Long delay should match standard duration for consistency"
        )
    }
}
