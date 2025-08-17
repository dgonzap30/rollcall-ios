//
// OnboardingCoordinatorTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

@testable import RollCall
import SwiftUI
import XCTest

@available(iOS 15.0, *)
@MainActor
final class OnboardingCoordinatorTests: XCTestCase {
    var sut: OnboardingCoordinator!
    var mockContainer: MockContainer!
    var mockDelegate: MockOnboardingCoordinatorDelegate!

    override func setUp() {
        super.setUp()
        self.mockContainer = MockContainer()
        self.mockDelegate = MockOnboardingCoordinatorDelegate()

        // Register required services
        self.mockContainer.register(HapticFeedbackServicing.self) {
            NoOpHapticFeedbackService()
        }

        self.sut = OnboardingCoordinator(container: self.mockContainer)
        self.sut.delegate = self.mockDelegate
    }

    override func tearDown() {
        self.sut = nil
        self.mockContainer = nil
        self.mockDelegate = nil
        super.tearDown()
    }

    // MARK: - Start Tests

    @MainActor
    func test_start_returnsWelcomeView() {
        let view = self.sut.start()

        // Verify view is created
        XCTAssertNotNil(view)

        // Verify container is passed to view model
        XCTAssertTrue(self.mockContainer.hasRegistered(HapticFeedbackServicing.self))
    }

    // MARK: - Delegate Tests

    @MainActor
    func test_onboardingCompleted_notifiesDelegate() {
        self.sut.onboardingCompleted()

        XCTAssertTrue(self.mockDelegate.onboardingCompletedCalled)
        XCTAssertEqual(self.mockDelegate.onboardingCompletedCallCount, 1)
    }

    @MainActor
    func test_onboardingCompleted_calledMultipleTimes_notifiesDelegateEachTime() {
        self.sut.onboardingCompleted()
        self.sut.onboardingCompleted()
        self.sut.onboardingCompleted()

        XCTAssertEqual(self.mockDelegate.onboardingCompletedCallCount, 3)
    }

    // MARK: - Memory Management Tests

    func test_coordinator_doesNotCreateRetainCycle() {
        weak var weakCoordinator: OnboardingCoordinator?
        weak var weakDelegate: MockOnboardingCoordinatorDelegate?

        autoreleasepool {
            let delegate = MockOnboardingCoordinatorDelegate()
            let coordinator = OnboardingCoordinator(container: mockContainer)
            coordinator.delegate = delegate

            weakCoordinator = coordinator
            weakDelegate = delegate

            Task { @MainActor in
                _ = coordinator.start()
                coordinator.onboardingCompleted()
            }
        }

        XCTAssertNil(weakCoordinator)
        XCTAssertNil(weakDelegate)
    }

    // MARK: - Integration Tests

    @MainActor
    func test_coordinatorFlow_startsAndCompletes() {
        // Start coordinator
        let view = self.sut.start()
        XCTAssertNotNil(view)

        // Complete onboarding
        self.sut.onboardingCompleted()

        // Verify delegate was called
        XCTAssertTrue(self.mockDelegate.onboardingCompletedCalled)
    }
}

// MARK: - Mock Delegate

@available(iOS 15.0, *)
final class MockOnboardingCoordinatorDelegate: OnboardingCoordinatorDelegate {
    private(set) var onboardingCompletedCalled = false
    private(set) var onboardingCompletedCallCount = 0
    private(set) var finishedCoordinator: OnboardingCoordinator?

    @MainActor
    func onboardingCoordinatorDidFinish(_ coordinator: OnboardingCoordinator) {
        self.onboardingCompletedCalled = true
        self.onboardingCompletedCallCount += 1
        self.finishedCoordinator = coordinator
    }
}
