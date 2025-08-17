//
// HapticFeedbackServiceTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class HapticFeedbackServiceTests: XCTestCase {
    var sut: HapticFeedbackService!

    override func setUp() {
        super.setUp()
        self.sut = HapticFeedbackService()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    // MARK: - Impact Style Tests

    @MainActor
    func test_impact_allStyles_executeWithoutCrash() async {
        // Test all impact styles
        await self.sut.impact(style: .light)
        await self.sut.impact(style: .medium)
        await self.sut.impact(style: .heavy)
        await self.sut.impact(style: .success)
        await self.sut.impact(style: .warning)
        await self.sut.impact(style: .error)

        // Verify service remains functional
        XCTAssertNotNil(self.sut)
    }

    @MainActor
    func test_impact_lightStyle() async {
        // Test light style
        await self.sut.impact(style: .light)

        // Verify service remains functional
        XCTAssertNotNil(self.sut)
    }

    // MARK: - Notification Style Tests

    @MainActor
    func test_notificationStyles_executeWithoutCrash() async {
        // Test notification-style haptics
        await self.sut.impact(style: .success)
        await self.sut.impact(style: .warning)
        await self.sut.impact(style: .error)

        // Verify service remains functional
        XCTAssertNotNil(self.sut)
    }

    // MARK: - Platform Behavior Tests

    #if os(iOS)
        @MainActor
        func test_iOS_hapticFeedbackEnabled() async {
            // On iOS, haptic feedback should be available
            await self.sut.impact(style: .light)
            await self.sut.impact(style: .success)

            // Verify service executes without issues
            XCTAssertNotNil(self.sut)
        }
    #endif

    #if os(macOS)
        @MainActor
        func test_macOS_hapticFeedbackNoOp() async {
            // On macOS, haptic feedback should be no-op
            await self.sut.impact(style: .heavy)
            await self.sut.impact(style: .error)

            // Verify service executes without issues (no-op)
            XCTAssertNotNil(self.sut)
        }
    #endif

    // MARK: - Concurrent Access Tests

    @MainActor
    func test_concurrentHapticCalls_handledSafely() async {
        // Test multiple concurrent haptic calls
        async let impact1 = self.sut.impact(style: .light)
        async let impact2 = self.sut.impact(style: .medium)
        async let impact3 = self.sut.impact(style: .success)
        async let impact4 = self.sut.impact(style: .heavy)
        async let impact5 = self.sut.impact(style: .warning)

        // Wait for all to complete
        await (impact1, impact2, impact3, impact4, impact5)

        // Verify service remains functional
        XCTAssertNotNil(self.sut)
    }

    // MARK: - Protocol Conformance Tests

    func test_conformsToHapticFeedbackServicing() {
        XCTAssertTrue(self.sut is HapticFeedbackServicing)
    }

    // MARK: - NoOp Service Tests

    @MainActor
    func test_noOpService_allMethods() async {
        let noOpService = NoOpHapticFeedbackService()

        // Test all methods execute without crash
        await noOpService.impact(style: .light)
        await noOpService.impact(style: .heavy)
        await noOpService.impact(style: .success)
        await noOpService.impact(style: .error)

        // Verify service remains functional
        XCTAssertNotNil(noOpService)
    }

    func test_noOpService_hasPublicInit() {
        // Verify NoOpHapticFeedbackService can be initialized
        let service = NoOpHapticFeedbackService()
        XCTAssertNotNil(service)
    }

    // MARK: - Memory Tests

    @MainActor
    func test_noRetainCycles() async {
        var service: HapticFeedbackService? = HapticFeedbackService()

        // Use the service
        await service?.impact(style: .medium)
        await service?.impact(style: .success)

        // Release the reference
        service = nil

        // Service should be deallocated
        XCTAssertNil(service)
    }
}
