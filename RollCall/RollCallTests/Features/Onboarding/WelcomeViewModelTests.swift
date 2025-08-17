//
// WelcomeViewModelTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Combine
@testable import RollCall
import XCTest

@available(iOS 15.0, *)
@MainActor
final class WelcomeViewModelTests: XCTestCase {
    private var sut: WelcomeViewModel!
    private var mockHapticService: MockHapticFeedbackService!
    private var mockAccessibilityService: MockAccessibilityService!
    private var mockDelegate: MockWelcomeViewModelDelegate!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        self.mockHapticService = MockHapticFeedbackService()
        self.mockAccessibilityService = MockAccessibilityService()
        self.mockDelegate = MockWelcomeViewModelDelegate()
        self.cancellables = []
        self.sut = WelcomeViewModel(
            hapticService: self.mockHapticService,
            accessibilityService: self.mockAccessibilityService,
            delegate: self.mockDelegate
        )
    }

    override func tearDown() {
        self.sut = nil
        self.mockHapticService = nil
        self.mockAccessibilityService = nil
        self.mockDelegate = nil
        self.cancellables = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func test_initialState_hasCorrectValues() {
        XCTAssertEqual(self.sut.viewState.logo.scale, 0.5)
        XCTAssertEqual(self.sut.viewState.logo.opacity, 0.0)
        XCTAssertEqual(self.sut.viewState.logo.rotation, -5.0)
        XCTAssertEqual(self.sut.viewState.logo.floatingOffset, 0.0)
        XCTAssertEqual(self.sut.viewState.logo.pulseScale, 1.0)
        XCTAssertEqual(self.sut.viewState.content.titleOpacity, 0.0)
        XCTAssertEqual(self.sut.viewState.content.subtitleOpacity, 0.0)
        XCTAssertEqual(self.sut.viewState.button.scale, 0.8)
        XCTAssertEqual(self.sut.viewState.button.opacity, 0.0)
        XCTAssertFalse(self.sut.viewState.button.isPressed)
        XCTAssertFalse(self.sut.viewState.showParticles)
        XCTAssertEqual(self.sut.viewState.animationPhase, .initial)
    }

    // MARK: - Animation Tests

    func test_startAnimations_progressesThroughPhases() async {
        let expectation = XCTestExpectation(description: "Animation completes")

        var phaseChanges: [WelcomeViewState.AnimationPhase] = []

        self.sut.$viewState
            .map(\.animationPhase)
            .sink { phase in
                phaseChanges.append(phase)
                if phase == .complete {
                    expectation.fulfill()
                }
            }
            .store(in: &self.cancellables)

        self.sut.startAnimations()

        await fulfillment(of: [expectation], timeout: 0.5)

        XCTAssertEqual(phaseChanges, [.initial, .logoIn, .contentIn, .buttonIn, .complete])
    }

    func test_startAnimations_updatesLogoState() async {
        let expectation = XCTestExpectation(description: "Logo animates in")

        self.sut.$viewState
            .dropFirst()
            .first()
            .sink { state in
                XCTAssertEqual(state.logo.scale, 1.0)
                XCTAssertEqual(state.logo.opacity, 1.0)
                XCTAssertEqual(state.logo.rotation, 0.0)
                expectation.fulfill()
            }
            .store(in: &self.cancellables)

        self.sut.startAnimations()

        await fulfillment(of: [expectation], timeout: 0.5)
    }

    func test_stopAnimations_cancelsAnimationTask() async {
        self.sut.startAnimations()

        try? await Task.sleep(nanoseconds: 100_000_000)

        self.sut.stopAnimations()

        let initialPhase = self.sut.viewState.animationPhase

        try? await Task.sleep(nanoseconds: 500_000_000)

        XCTAssertEqual(self.sut.viewState.animationPhase, initialPhase)
    }

    // MARK: - Button Press Tests

    func test_handleButtonPress_triggersHapticFeedback() async {
        await self.sut.handleButtonPress()

        XCTAssertEqual(self.mockHapticService.impactCallCount, 1)
        XCTAssertEqual(self.mockHapticService.lastImpactStyle, .light)
    }

    func test_handleButtonPress_triggersHapticOnlyOnce() async {
        await self.sut.handleButtonPress()
        await self.sut.handleButtonPress()
        await self.sut.handleButtonPress()

        XCTAssertEqual(self.mockHapticService.impactCallCount, 1)
    }

    func test_handleButtonPress_updatesButtonState() async {
        let expectation = XCTestExpectation(description: "Button state changes")

        var buttonStates: [Bool] = []

        self.sut.$viewState
            .map(\.button.isPressed)
            .sink { isPressed in
                buttonStates.append(isPressed)
                if buttonStates.count == 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &self.cancellables)

        await self.sut.handleButtonPress()

        await fulfillment(of: [expectation], timeout: 0.5)

        XCTAssertEqual(buttonStates, [false, true, false])
    }

    func test_handleButtonPress_notifiesDelegate() async {
        await self.sut.handleButtonPress()

        XCTAssertEqual(self.mockDelegate.getStartedCallCount, 1)
    }

    // MARK: - Phase Progression Tests

    func test_viewState_nextPhase_progressesCorrectly() {
        var state = WelcomeViewState.initial

        state.nextPhase()
        XCTAssertEqual(state.animationPhase, .logoIn)
        XCTAssertEqual(state.logo.scale, 1.0)

        state.nextPhase()
        XCTAssertEqual(state.animationPhase, .contentIn)
        XCTAssertEqual(state.content.titleOpacity, 1.0)
        XCTAssertEqual(state.logo.floatingOffset, -2.0)
        XCTAssertEqual(state.logo.pulseScale, 1.02)

        state.nextPhase()
        XCTAssertEqual(state.animationPhase, .buttonIn)
        XCTAssertEqual(state.button.scale, 1.0)

        state.nextPhase()
        XCTAssertEqual(state.animationPhase, .complete)
        XCTAssertTrue(state.showParticles)

        state.nextPhase()
        XCTAssertEqual(state.animationPhase, .complete)
    }
}

// MARK: - Mock Classes

@available(iOS 15.0, *)
private final class MockWelcomeViewModelDelegate: WelcomeViewModelDelegate {
    var getStartedCallCount = 0

    func welcomeViewModelDidTapGetStarted() {
        self.getStartedCallCount += 1
    }
}
