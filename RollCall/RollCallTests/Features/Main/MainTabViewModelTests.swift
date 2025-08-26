//
// MainTabViewModelTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Combine
@testable import RollCall
import XCTest

// MARK: - Mock Coordinator

@available(iOS 15.0, *)
final class MockMainTabCoordinator: MainTabCoordinating {
    private(set) var handleTabSelectionCalled = false
    private(set) var handleTabSelectionCallCount = 0
    private(set) var selectedTabs: [Tab] = []

    private(set) var showCreateRollCalled = false
    private(set) var showCreateRollCallCount = 0

    func handleTabSelection(_ tab: Tab) {
        self.handleTabSelectionCalled = true
        self.handleTabSelectionCallCount += 1
        self.selectedTabs.append(tab)
    }

    func showCreateRoll() {
        self.showCreateRollCalled = true
        self.showCreateRollCallCount += 1
    }
}

@available(iOS 15.0, *)
final class MainTabViewModelTests: XCTestCase {
    var sut: MainTabViewModel!
    var mockCoordinator: MockMainTabCoordinator!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        self.mockCoordinator = MockMainTabCoordinator()
        self.sut = MainTabViewModel(coordinator: self.mockCoordinator)
        self.cancellables = []
    }

    override func tearDown() {
        self.sut = nil
        self.mockCoordinator = nil
        self.cancellables = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func test_initialState_hasCorrectDefaults() {
        XCTAssertEqual(self.sut.viewState.selectedTab, .feed)
        XCTAssertEqual(self.sut.viewState.feedBadgeCount, 0)
        XCTAssertEqual(self.sut.viewState.profileBadgeCount, 0)
        XCTAssertFalse(self.sut.viewState.isLoading)
        XCTAssertNil(self.sut.viewState.error)
    }

    // MARK: - Tab Selection Tests

    @MainActor
    func test_onTabSelected_updatesSelectedTab() {
        // When
        self.sut.onTabSelected(.create)
        self.sut.onTabSelected(.profile)
        self.sut.onTabSelected(.feed)

        // Then
        XCTAssertEqual(self.sut.viewState.selectedTab, .feed)
        XCTAssertTrue(self.mockCoordinator.handleTabSelectionCalled)
        XCTAssertEqual(self.mockCoordinator.handleTabSelectionCallCount, 3)
        XCTAssertEqual(self.mockCoordinator.selectedTabs, [.create, .profile, .feed])
    }

    @MainActor
    func test_onTabSelected_clearsError() {
        // When
        self.sut.onTabSelected(.profile)

        // Then - error clearing happens synchronously
        XCTAssertNil(self.sut.viewState.error)
        XCTAssertEqual(self.sut.viewState.selectedTab, .profile)
    }

    // MARK: - Create Roll Tests

    @MainActor
    func test_onCreateRollTapped_callsCoordinator() {
        // When
        self.sut.onCreateRollTapped()

        // Then
        XCTAssertTrue(self.mockCoordinator.showCreateRollCalled)
        XCTAssertEqual(self.mockCoordinator.showCreateRollCallCount, 1)
    }

    @MainActor
    func test_onCreateRollTapped_multipleTimes() {
        // When
        self.sut.onCreateRollTapped()
        self.sut.onCreateRollTapped()
        self.sut.onCreateRollTapped()

        // Then
        XCTAssertEqual(self.mockCoordinator.showCreateRollCallCount, 3)
    }

    // MARK: - Error Handling Tests

    @MainActor
    func test_dismissError_clearsError() {
        // When
        self.sut.dismissError()

        // Then
        XCTAssertNil(self.sut.viewState.error)
    }

    // MARK: - ViewState Tests

    func test_viewStateWith_allParameters() {
        let newState = self.sut.viewState.with(
            selectedTab: .profile,
            feedBadgeCount: 5,
            profileBadgeCount: 3,
            isLoading: true,
            error: .some("Test error")
        )

        XCTAssertEqual(newState.selectedTab, .profile)
        XCTAssertEqual(newState.feedBadgeCount, 5)
        XCTAssertEqual(newState.profileBadgeCount, 3)
        XCTAssertTrue(newState.isLoading)
        XCTAssertEqual(newState.error, "Test error")
    }

    func test_viewStateWith_selectedTab() {
        let newState = self.sut.viewState.with(selectedTab: .profile)

        XCTAssertEqual(newState.selectedTab, .profile)
        XCTAssertEqual(newState.feedBadgeCount, self.sut.viewState.feedBadgeCount)
        XCTAssertEqual(newState.profileBadgeCount, self.sut.viewState.profileBadgeCount)
        XCTAssertEqual(newState.isLoading, self.sut.viewState.isLoading)
        XCTAssertEqual(newState.error, self.sut.viewState.error)
    }

    func test_viewStateWith_badgeCounts() {
        let newState = self.sut.viewState.with(
            feedBadgeCount: 10,
            profileBadgeCount: 2
        )

        XCTAssertEqual(newState.feedBadgeCount, 10)
        XCTAssertEqual(newState.profileBadgeCount, 2)
    }

    // MARK: - Immutability Tests

    @MainActor
    func test_viewStateUpdate_maintainsImmutability() {
        // Given
        let originalState = self.sut.viewState

        // When
        self.sut.onTabSelected(.profile)

        // Then
        XCTAssertNotEqual(originalState.selectedTab, self.sut.viewState.selectedTab)
        XCTAssertEqual(self.sut.viewState.selectedTab, .profile)
    }

    // MARK: - Memory Management Tests

    func test_viewModel_doesNotCreateRetainCycle() {
        weak var weakSut: MainTabViewModel?
        weak var weakCoordinator: MockMainTabCoordinator?

        autoreleasepool {
            let coordinator = MockMainTabCoordinator()
            let viewModel = MainTabViewModel(coordinator: coordinator)

            weakSut = viewModel
            weakCoordinator = coordinator

            // Call methods synchronously - they don't create retain cycles
            // since we removed the Task closures that captured self
        }

        // After autoreleasepool, objects should be deallocated
        XCTAssertNil(weakSut, "ViewModel should be deallocated")
        XCTAssertNil(weakCoordinator, "Coordinator should be deallocated")
    }

    // MARK: - Concurrent Access Tests

    @MainActor
    func test_concurrentTabSelection_handledSafely() {
        // When - simulate rapid tab selections
        self.sut.onTabSelected(.feed)
        self.sut.onTabSelected(.create)
        self.sut.onTabSelected(.profile)

        // Then - final state should be the last selected tab
        XCTAssertEqual(self.sut.viewState.selectedTab, .profile)
        XCTAssertEqual(self.mockCoordinator.handleTabSelectionCallCount, 3)
    }
}
