//
// OnboardingCoordinator.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation
#if canImport(SwiftUI)
    import SwiftUI
#endif

@available(iOS 15.0, macOS 12.0, *)
protocol OnboardingCoordinatorDelegate: AnyObject {
    @MainActor
    func onboardingCoordinatorDidFinish(_ coordinator: OnboardingCoordinator)
}

@available(iOS 15.0, macOS 12.0, *)
@MainActor
public final class OnboardingCoordinator: OnboardingViewModelDelegate, WelcomeViewModelDelegate {
    weak var delegate: OnboardingCoordinatorDelegate?
    private let container: Container
    private var onboardingViewModel: OnboardingViewModel?

    public init(container: Container) {
        self.container = container
    }

    public func start() -> OnboardingContainerView {
        let hapticService: HapticFeedbackServicing = self.container.resolve(HapticFeedbackServicing.self)
        let userPreferencesService: UserPreferencesServicing = self.container.resolve(UserPreferencesServicing.self)

        let onboardingViewModel = OnboardingViewModel(
            hapticService: hapticService,
            userPreferencesService: userPreferencesService,
            delegate: self
        )
        self.onboardingViewModel = onboardingViewModel

        let accessibilityService: AccessibilityServicing = self.container.resolve(AccessibilityServicing.self)

        let welcomeViewModel = WelcomeViewModel(
            hapticService: hapticService,
            accessibilityService: accessibilityService,
            delegate: self
        )

        return OnboardingContainerView(
            viewModel: onboardingViewModel,
            welcomeViewModel: welcomeViewModel
        )
    }

    func onboardingCompleted() {
        self.delegate?.onboardingCoordinatorDidFinish(self)
    }

    func onboardingDidComplete() {
        Task { @MainActor [weak self] in
            self?.onboardingCompleted()
        }
    }

    public func welcomeViewModelDidTapGetStarted() {
        #if DEBUG
            print("[OnboardingCoordinator] welcomeViewModelDidTapGetStarted called")
            print("[OnboardingCoordinator] Calling onboardingViewModel.onGetStartedTapped")
        #endif
        self.onboardingViewModel?.onGetStartedTapped()
    }

    deinit {
        #if DEBUG
            print("[OnboardingCoordinator] deinit")
        #endif
    }
}
