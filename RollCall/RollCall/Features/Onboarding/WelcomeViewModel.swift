//
// WelcomeViewModel.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Combine
import Foundation

@MainActor
public protocol WelcomeViewModelDelegate: AnyObject {
    func welcomeViewModelDidTapGetStarted()
}

@available(iOS 15.0, *)
public final class WelcomeViewModel: ObservableObject {
    weak var delegate: WelcomeViewModelDelegate?

    @Published public private(set) var viewState = WelcomeViewState.initial

    private let hapticService: HapticFeedbackServicing
    private let accessibilityService: AccessibilityServicing
    private var animationTask: Task<Void, Never>?
    private var floatingAnimationTask: Task<Void, Never>?
    private var hasTriggeredHaptic = false

    public init(
        hapticService: HapticFeedbackServicing,
        accessibilityService: AccessibilityServicing,
        delegate: WelcomeViewModelDelegate? = nil
    ) {
        self.hapticService = hapticService
        self.accessibilityService = accessibilityService
        self.delegate = delegate
    }

    public func startAnimations() {
        self.animationTask?.cancel()
        self.floatingAnimationTask?.cancel()

        self.animationTask = Task { [weak self] in
            await self?.performAnimationSequence()
        }

        self.floatingAnimationTask = Task { [weak self] in
            await self?.performFloatingAnimations()
        }
    }

    public func stopAnimations() {
        self.animationTask?.cancel()
        self.animationTask = nil
        self.floatingAnimationTask?.cancel()
        self.floatingAnimationTask = nil
    }

    public func handleButtonPress() async {
        await MainActor.run {
            self.viewState.setButtonPressed(true)
        }

        if !self.hasTriggeredHaptic {
            self.hasTriggeredHaptic = true
            await self.hapticService.impact(style: .light)
        }

        try? await Task.sleep(nanoseconds: 100_000_000)

        await MainActor.run {
            self.viewState.setButtonPressed(false)
        }

        await self.delegate?.welcomeViewModelDidTapGetStarted()
    }

    private func performAnimationSequence() async {
        for phase in 1...4 {
            guard !Task.isCancelled else { return }

            await MainActor.run {
                self.viewState.nextPhase()
            }

            let delay: UInt64 = phase == 1 ? 300_000_000 : 200_000_000
            try? await Task.sleep(nanoseconds: delay)
        }
    }

    private func performFloatingAnimations() async {
        guard !self.accessibilityService.isReduceMotionEnabled else { return }

        while !Task.isCancelled {
            await MainActor.run {
                self.viewState.logo.floatingOffset = 10
            }

            try? await Task.sleep(nanoseconds: 1_500_000_000)

            await MainActor.run {
                self.viewState.logo.floatingOffset = -2
            }

            try? await Task.sleep(nanoseconds: 1_500_000_000)

            await MainActor.run {
                self.viewState.logo.pulseScale = 1.05
            }

            try? await Task.sleep(nanoseconds: 1_000_000_000)

            await MainActor.run {
                self.viewState.logo.pulseScale = 1.02
            }

            try? await Task.sleep(nanoseconds: 1_000_000_000)
        }
    }

    deinit {
        animationTask?.cancel()
        floatingAnimationTask?.cancel()

        #if DEBUG
            print("[WelcomeViewModel] deinit")
        #endif
    }
}
