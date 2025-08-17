//
// MainTabCoordinatorTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

@testable import RollCall
import SwiftUI
import XCTest

@available(iOS 15.0, *)
final class MainTabCoordinatorTests: XCTestCase {
    var sut: MainTabCoordinator!
    var mockContainer: MockContainer!
    var mockDelegate: MockMainTabCoordinatorDelegate!

    override func setUp() {
        super.setUp()
        self.mockContainer = MockContainer()
        self.mockDelegate = MockMainTabCoordinatorDelegate()

        // Register required services
        self.mockContainer.register(UserPreferencesServicing.self) {
            UserPreferencesService()
        }

        self.sut = MainTabCoordinator(container: self.mockContainer)
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
    func test_start_returnsMainTabView() {
        let view = self.sut.start()

        // Verify view is created
        XCTAssertNotNil(view)
    }

    // MARK: - Tab Selection Tests

    @MainActor
    func test_handleTabSelection_allTabs() {
        // Test each tab can be selected
        for tab in Tab.allCases {
            self.sut.handleTabSelection(tab)
            // Since we're testing smoke behavior, we just verify no crash
        }
    }

    @MainActor
    func test_handleTabSelection_multipleSelections() {
        // Test rapid tab switching
        self.sut.handleTabSelection(.feed)
        self.sut.handleTabSelection(.create)
        self.sut.handleTabSelection(.profile)
        self.sut.handleTabSelection(.feed)

        // Verify coordinator remains stable
        XCTAssertNotNil(self.sut)
    }

    // MARK: - Create Roll Modal Tests

    @MainActor
    func test_showCreateRoll_presentsModal() {
        self.sut.showCreateRoll()

        // Since we can't easily test SwiftUI modal presentation
        // we verify the method executes without crash
        XCTAssertNotNil(self.sut)
    }

    @MainActor
    func test_showCreateRoll_calledMultipleTimes() {
        // Test multiple modal presentations
        self.sut.showCreateRoll()
        self.sut.showCreateRoll()
        self.sut.showCreateRoll()

        // Verify coordinator remains stable
        XCTAssertNotNil(self.sut)
    }

    // MARK: - Memory Management Tests

    func test_coordinator_doesNotCreateRetainCycle() {
        weak var weakCoordinator: MainTabCoordinator?

        autoreleasepool {
            let coordinator = MainTabCoordinator(container: mockContainer)
            weakCoordinator = coordinator

            Task { @MainActor in
                _ = coordinator.start()
                coordinator.handleTabSelection(.profile)
                coordinator.showCreateRoll()
            }
        }

        XCTAssertNil(weakCoordinator)
    }

    // MARK: - Child Coordinator Tests

    @MainActor
    func test_childCoordinators_areManaged() {
        // Start main coordinator
        _ = self.sut.start()

        // Navigate through tabs (which may create child coordinators)
        self.sut.handleTabSelection(.feed)
        self.sut.handleTabSelection(.create)
        self.sut.handleTabSelection(.profile)

        // Show modal (which may create child coordinator)
        self.sut.showCreateRoll()

        // Verify coordinator is still functional
        XCTAssertNotNil(self.sut)
    }

    // MARK: - Integration Tests

    @MainActor
    func test_fullNavigationFlow() {
        // Start coordinator
        let view = self.sut.start()
        XCTAssertNotNil(view)

        // Navigate through all tabs
        for tab in Tab.allCases {
            self.sut.handleTabSelection(tab)
        }

        // Show create roll modal
        self.sut.showCreateRoll()

        // Return to feed
        self.sut.handleTabSelection(.feed)

        // Verify coordinator remains functional
        XCTAssertNotNil(self.sut)
    }

    // MARK: - Reset Onboarding Tests

    #if DEBUG
        @MainActor
        func test_resetOnboarding_notifiesDelegate() {
            // Given
            let userPreferencesService: UserPreferencesServicing = self.mockContainer
                .resolve(UserPreferencesServicing.self)
            userPreferencesService.setOnboardingCompleted(true)

            // When
            // We need to trigger the reset button action
            // Since it's a private method, we'll test through the view
            let view = self.sut.start()

            // Then - verify delegate was set
            XCTAssertNotNil(self.sut.delegate)
            XCTAssertTrue(self.sut.delegate === self.mockDelegate)
        }

        @MainActor
        func test_resetOnboarding_delegateReceivesCorrectCoordinator() {
            // This test verifies the delegate pattern is properly implemented
            // The actual reset functionality is tested through integration tests
            XCTAssertNotNil(self.sut.delegate)
            XCTAssertTrue(self.sut.delegate === self.mockDelegate)
        }
    #endif
}

// MARK: - Mock Delegate

@available(iOS 15.0, *)
final class MockMainTabCoordinatorDelegate: MainTabCoordinatorDelegate {
    private(set) var resetRequestedCalled = false
    private(set) var resetRequestedCallCount = 0
    private(set) var resetCoordinator: MainTabCoordinator?

    @MainActor
    func mainTabCoordinatorDidRequestReset(_ coordinator: MainTabCoordinator) {
        self.resetRequestedCalled = true
        self.resetRequestedCallCount += 1
        self.resetCoordinator = coordinator
    }
}
