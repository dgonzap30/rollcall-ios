//
// MockUserPreferencesService.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation
@testable import RollCall

final class MockUserPreferencesService: UserPreferencesServicing {
    var hasCompletedOnboarding: Bool = false
    var hasSkippedOnboarding: Bool = false
    var lastOnboardingPage: Int = 0

    var setOnboardingCompletedCallCount = 0
    var setOnboardingSkippedCallCount = 0
    var setLastOnboardingPageCallCount = 0

    func setOnboardingCompleted(_ completed: Bool) {
        self.hasCompletedOnboarding = completed
        self.setOnboardingCompletedCallCount += 1
    }

    func setOnboardingSkipped(_ skipped: Bool) {
        self.hasSkippedOnboarding = skipped
        self.setOnboardingSkippedCallCount += 1
    }

    func setLastOnboardingPage(_ page: Int) {
        self.lastOnboardingPage = page
        self.setLastOnboardingPageCallCount += 1
    }
}
