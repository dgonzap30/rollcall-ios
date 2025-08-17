//
// OnboardingViewState.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

struct OnboardingViewState: Equatable {
    let currentPageIndex: Int
    let pages: [OnboardingPage]
    let isSkipVisible: Bool
    let isLastPage: Bool
    let canNavigateForward: Bool

    init(
        currentPageIndex: Int = 0,
        pages: [OnboardingPage] = OnboardingPage.pages
    ) {
        self.currentPageIndex = currentPageIndex
        self.pages = pages
        self.isSkipVisible = currentPageIndex > 0 && currentPageIndex < pages.count - 1
        self.isLastPage = currentPageIndex == pages.count - 1
        self.canNavigateForward = currentPageIndex < pages.count - 1
    }

    var currentPage: OnboardingPage? {
        guard self.currentPageIndex >= 0 && self.currentPageIndex < self.pages.count else { return nil }
        return self.pages[self.currentPageIndex]
    }
}
