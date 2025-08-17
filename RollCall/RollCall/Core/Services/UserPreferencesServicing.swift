//
// UserPreferencesServicing.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

protocol UserPreferencesServicing {
    var hasCompletedOnboarding: Bool { get }
    var hasSkippedOnboarding: Bool { get }
    var lastOnboardingPage: Int { get }

    func setOnboardingCompleted(_ completed: Bool)
    func setOnboardingSkipped(_ skipped: Bool)
    func setLastOnboardingPage(_ page: Int)
}
