//
// UserPreferencesService.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

final class UserPreferencesService: UserPreferencesServicing {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var hasCompletedOnboarding: Bool {
        self.userDefaults.bool(forKey: OnboardingConstants.UserDefaults.onboardingCompletedKey)
    }

    var hasSkippedOnboarding: Bool {
        self.userDefaults.bool(forKey: OnboardingConstants.UserDefaults.onboardingSkippedKey)
    }

    var lastOnboardingPage: Int {
        self.userDefaults.integer(forKey: OnboardingConstants.UserDefaults.onboardingLastPageKey)
    }

    func setOnboardingCompleted(_ completed: Bool) {
        self.userDefaults.set(completed, forKey: OnboardingConstants.UserDefaults.onboardingCompletedKey)
    }

    func setOnboardingSkipped(_ skipped: Bool) {
        self.userDefaults.set(skipped, forKey: OnboardingConstants.UserDefaults.onboardingSkippedKey)
    }

    func setLastOnboardingPage(_ page: Int) {
        self.userDefaults.set(page, forKey: OnboardingConstants.UserDefaults.onboardingLastPageKey)
    }
}
