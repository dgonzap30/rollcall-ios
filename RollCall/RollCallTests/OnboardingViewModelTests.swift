//
// OnboardingViewModelTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class OnboardingViewModelTests: XCTestCase {
    private var sut: OnboardingViewModel!
    private var mockHapticService: TestHapticFeedbackService!
    private var mockUserPreferencesService: MockUserPreferencesService!
    private var mockDelegate: MockOnboardingViewModelDelegate!

    override func setUp() {
        super.setUp()
        self.mockHapticService = TestHapticFeedbackService()
        self.mockUserPreferencesService = MockUserPreferencesService()
        self.mockDelegate = MockOnboardingViewModelDelegate()

        self.sut = OnboardingViewModel(
            hapticService: self.mockHapticService,
            userPreferencesService: self.mockUserPreferencesService,
            delegate: self.mockDelegate
        )
    }

    override func tearDown() {
        self.mockUserPreferencesService = nil
        self.mockHapticService = nil
        self.mockDelegate = nil
        self.sut = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func test_init_shouldSetupInitialState() {
        XCTAssertEqual(self.sut.viewState.currentPageIndex, 0)
        XCTAssertEqual(self.sut.viewState.pages.count, 3)
        XCTAssertFalse(self.sut.viewState.isSkipVisible)
        XCTAssertFalse(self.sut.viewState.isLastPage)
        XCTAssertTrue(self.sut.viewState.canNavigateForward)
        XCTAssertEqual(self.sut.selection, 0)
    }

    // MARK: - Page Navigation Tests

    func test_onPageChanged_whenChangingToNewPage_shouldUpdateStateAndTriggerHaptic() async {
        self.sut.onPageChanged(to: 1)

        // Wait for async haptic to complete
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms

        XCTAssertEqual(self.sut.viewState.currentPageIndex, 1)
        XCTAssertEqual(self.sut.selection, 1)
        XCTAssertTrue(self.sut.viewState.isSkipVisible)
        XCTAssertFalse(self.sut.viewState.isLastPage)
        XCTAssertEqual(self.mockHapticService.impactCallCount, 1)
        XCTAssertEqual(self.mockHapticService.lastImpactStyle, .light)
        XCTAssertEqual(self.mockUserPreferencesService.lastOnboardingPage, 1)
        XCTAssertEqual(self.mockUserPreferencesService.setLastOnboardingPageCallCount, 1)
    }

    func test_onPageChanged_whenChangingToSamePage_shouldNotTriggerHaptic() {
        self.sut.onPageChanged(to: 0)

        XCTAssertEqual(self.mockHapticService.impactCallCount, 0)
    }

    func test_onPageChanged_whenOnLastPage_shouldHideSkipButton() async {
        self.sut.onPageChanged(to: 2)

        // Wait for async state update
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms

        XCTAssertEqual(self.sut.viewState.currentPageIndex, 2)
        XCTAssertEqual(self.sut.selection, 2)
        XCTAssertFalse(self.sut.viewState.isSkipVisible)
        XCTAssertTrue(self.sut.viewState.isLastPage)
        XCTAssertFalse(self.sut.viewState.canNavigateForward)
    }

    // MARK: - Button Action Tests

    func test_onNextTapped_whenNotOnLastPage_shouldMoveToNextPage() async {
        self.sut.onNextTapped()

        // Wait for async haptic to complete
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms

        XCTAssertEqual(self.sut.viewState.currentPageIndex, 1)
        XCTAssertEqual(self.sut.selection, 1)
        XCTAssertEqual(self.mockHapticService.impactCallCount, 1)
    }

    func test_onNextTapped_whenOnLastPage_shouldCompleteOnboarding() async {
        self.sut.onPageChanged(to: 2)
        self.mockHapticService.reset()

        self.sut.onNextTapped()

        // Wait for async haptic to complete
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms

        XCTAssertTrue(self.mockUserPreferencesService.hasCompletedOnboarding)
        XCTAssertFalse(self.mockUserPreferencesService.hasSkippedOnboarding)
        XCTAssertTrue(self.mockDelegate.didCompleteOnboarding)
        XCTAssertEqual(self.mockHapticService.impactCallCount, 1)
        XCTAssertEqual(self.mockUserPreferencesService.setOnboardingCompletedCallCount, 1)
    }

    func test_onSkipTapped_shouldCompleteOnboardingAsSkipped() async {
        self.sut.onPageChanged(to: 1)

        // Wait for state to update
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms

        self.mockHapticService.reset()

        self.sut.onSkipTapped()

        // Wait for async haptic to complete
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms

        XCTAssertTrue(self.mockUserPreferencesService.hasCompletedOnboarding)
        XCTAssertTrue(self.mockUserPreferencesService.hasSkippedOnboarding)
        XCTAssertEqual(self.mockUserPreferencesService.lastOnboardingPage, 1)
        XCTAssertTrue(self.mockDelegate.didCompleteOnboarding)
        XCTAssertEqual(self.mockHapticService.impactCallCount, 1)
        XCTAssertEqual(self.mockUserPreferencesService.setOnboardingSkippedCallCount, 1)
    }

    func test_onGetStartedTapped_whenOnFirstPage_shouldMoveToSecondPage() async {
        self.sut.onGetStartedTapped()

        // Wait for async haptic to complete
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms

        XCTAssertEqual(self.sut.viewState.currentPageIndex, 1)
        XCTAssertEqual(self.sut.selection, 1)
        XCTAssertEqual(self.mockHapticService.impactCallCount, 1)
    }

    func test_onGetStartedTapped_whenNotOnFirstPage_shouldCompleteOnboarding() {
        self.sut.onPageChanged(to: 1)
        self.mockHapticService.reset()

        self.sut.onGetStartedTapped()

        XCTAssertTrue(self.mockUserPreferencesService.hasCompletedOnboarding)
        XCTAssertFalse(self.mockUserPreferencesService.hasSkippedOnboarding)
        XCTAssertTrue(self.mockDelegate.didCompleteOnboarding)
    }

    // MARK: - Selection Binding Tests

    func test_selection_shouldSyncWithCurrentPageIndex() async {
        // Initial state
        XCTAssertEqual(self.sut.selection, 0)
        XCTAssertEqual(self.sut.viewState.currentPageIndex, 0)

        // Change page
        self.sut.onPageChanged(to: 1)
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms

        XCTAssertEqual(self.sut.selection, 1)
        XCTAssertEqual(self.sut.viewState.currentPageIndex, 1)

        // Change page again
        self.sut.onPageChanged(to: 2)
        try? await Task.sleep(nanoseconds: 10_000_000) // 10ms

        XCTAssertEqual(self.sut.selection, 2)
        XCTAssertEqual(self.sut.viewState.currentPageIndex, 2)
    }

    // MARK: - Memory Leak Tests

    func test_viewModel_shouldNotRetainDelegate() {
        var delegate: MockOnboardingViewModelDelegate? = MockOnboardingViewModelDelegate()
        weak var weakDelegate = delegate

        let viewModel = OnboardingViewModel(
            hapticService: mockHapticService,
            userPreferencesService: mockUserPreferencesService,
            delegate: delegate
        )

        delegate = nil

        XCTAssertNil(weakDelegate)
        XCTAssertNotNil(viewModel) // Keep compiler happy
    }
}

// MARK: - Mock Classes

@available(iOS 15.0, *)
private final class MockOnboardingViewModelDelegate: OnboardingViewModelDelegate {
    var didCompleteOnboarding = false

    func onboardingDidComplete() {
        self.didCompleteOnboarding = true
    }
}

@available(iOS 15.0, *)
private final class TestHapticFeedbackService: HapticFeedbackServicing {
    var impactCallCount = 0
    var lastImpactStyle: HapticFeedbackStyle?
    var notificationCallCount = 0
    var lastNotificationType: HapticNotificationType?

    func impact(style: HapticFeedbackStyle) async {
        self.impactCallCount += 1
        self.lastImpactStyle = style
    }

    func notification(type: HapticNotificationType) async {
        self.notificationCallCount += 1
        self.lastNotificationType = type
    }

    func reset() {
        self.impactCallCount = 0
        self.lastImpactStyle = nil
        self.notificationCallCount = 0
        self.lastNotificationType = nil
    }
}
