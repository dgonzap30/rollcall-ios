//
// OnboardingPage.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

struct OnboardingPage: Identifiable, Equatable {
    let id: Int
    let illustration: String
    let title: String
    let subtitle: String
    let buttonTitle: String?

    static let pages: [Self] = [
        Self(
            id: 0,
            illustration: "welcome",
            title: "Welcome to RollCall",
            subtitle: "Your personal sushi journey starts here",
            buttonTitle: "Get Started"
        ),
        Self(
            id: 1,
            illustration: "track_rolls",
            title: "Track Your Sushi Journey",
            subtitle: "Log every roll, rate your favorites, and build your personal sushi diary",
            buttonTitle: "Next"
        ),
        Self(
            id: 2,
            illustration: "discover_share",
            title: "Discover & Share",
            subtitle: "Find amazing restaurants, follow fellow chefs, and share your sushi adventures",
            buttonTitle: "Start Rolling"
        )
    ]
}
