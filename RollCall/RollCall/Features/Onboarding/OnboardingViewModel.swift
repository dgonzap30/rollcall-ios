//
// OnboardingViewModel.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Combine
import Foundation

protocol OnboardingViewModelDelegate: AnyObject {
    @MainActor
    func onboardingDidComplete()
}

final class OnboardingViewModel: ObservableObject {
    @Published private(set) var viewState: OnboardingViewState
    @Published var selection: Int = 0

    weak var delegate: OnboardingViewModelDelegate?
    private let hapticService: HapticFeedbackServicing
    private let userPreferencesService: UserPreferencesServicing

    private var currentPageIndex = 0 {
        didSet {
            #if DEBUG
                print("[OnboardingViewModel] currentPageIndex changed from \(oldValue) to \(self.currentPageIndex)")
            #endif
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.selection = self.currentPageIndex
                #if DEBUG
                    print("[OnboardingViewModel] selection updated to \(self.selection)")
                #endif
                self.updateViewState()
            }
        }
    }

    init(
        hapticService: HapticFeedbackServicing = HapticFeedbackService(),
        userPreferencesService: UserPreferencesServicing = UserPreferencesService(),
        delegate: OnboardingViewModelDelegate? = nil
    ) {
        self.hapticService = hapticService
        self.userPreferencesService = userPreferencesService
        self.delegate = delegate
        self.viewState = OnboardingViewState(currentPageIndex: 0)
    }

    func onPageChanged(to index: Int) {
        guard index != self.currentPageIndex else { return }
        self.currentPageIndex = index
        Task { [weak self] in
            await self?.hapticService.impact(style: .light)
        }
        self.userPreferencesService.setLastOnboardingPage(index)
    }

    func onNextTapped() {
        guard self.viewState.canNavigateForward else {
            self.completeOnboarding(skipped: false)
            return
        }

        Task { [weak self] in
            await self?.hapticService.impact(style: .light)
        }
        self.currentPageIndex += 1
    }

    func onSkipTapped() {
        #if DEBUG
            print("[OnboardingViewModel] onSkipTapped called")
        #endif

        Task { [weak self] in
            await self?.hapticService.impact(style: .light)
        }

        #if DEBUG
            print("[OnboardingViewModel] Completing onboarding with skip")
        #endif

        self.completeOnboarding(skipped: true)
    }

    func onGetStartedTapped() {
        #if DEBUG
            print("[OnboardingViewModel] onGetStartedTapped - currentPageIndex: \(self.currentPageIndex)")
        #endif

        Task { [weak self] in
            await self?.hapticService.impact(style: .light)
        }

        if self.currentPageIndex == 0 {
            self.currentPageIndex = 1
            #if DEBUG
                print("[OnboardingViewModel] Moving to page 1, selection: \(self.selection)")
            #endif
        } else {
            #if DEBUG
                print("[OnboardingViewModel] Completing onboarding")
            #endif
            self.completeOnboarding(skipped: false)
        }
    }

    @MainActor
    private func updateViewState() {
        self.viewState = OnboardingViewState(
            currentPageIndex: self.currentPageIndex,
            pages: OnboardingPage.pages
        )
    }

    private func completeOnboarding(skipped: Bool) {
        #if DEBUG
            print(
                "[OnboardingViewModel] completeOnboarding - " +
                    "skipped: \(skipped), currentPageIndex: \(self.currentPageIndex)"
            )
        #endif

        self.userPreferencesService.setOnboardingCompleted(true)
        self.userPreferencesService.setOnboardingSkipped(skipped)
        self.userPreferencesService.setLastOnboardingPage(self.currentPageIndex)

        #if DEBUG
            print("[OnboardingViewModel] Calling delegate.onboardingDidComplete()")
        #endif

        Task { @MainActor in
            self.delegate?.onboardingDidComplete()
        }
    }

    deinit {
        #if DEBUG
            print("[OnboardingViewModel] deinit")
        #endif
    }
}
