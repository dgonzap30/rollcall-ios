//
// OnboardingConstants.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation
import SwiftUI

enum OnboardingConstants {
    enum Layout {
        static let horizontalPadding: CGFloat = 20
        static let verticalSpacing: CGFloat = 56
        static let illustrationHeight: CGFloat = 280
        static let buttonHeight: CGFloat = 56
        static let pageIndicatorSpacing: CGFloat = 8
        static let pageIndicatorSize: CGFloat = 8
        static let skipButtonPadding: CGFloat = 16
    }

    enum Animation {
        static let pageTransitionDuration: Double = 0.2
        static let fadeInDuration: Double = 0.3
        static let buttonPressDuration: Double = 0.1
        static let standardCurve: SwiftUI.Animation = .easeInOut(duration: pageTransitionDuration)
    }

    enum Typography {
        static let titleSize: CGFloat = 32
        static let subtitleSize: CGFloat = 17
        static let skipButtonSize: CGFloat = 17
    }

    enum UserDefaults {
        static let onboardingCompletedKey = "com.rollcall.onboarding.completed"
        static let onboardingSkippedKey = "com.rollcall.onboarding.skipped"
        static let onboardingLastPageKey = "com.rollcall.onboarding.lastPage"
    }
}
