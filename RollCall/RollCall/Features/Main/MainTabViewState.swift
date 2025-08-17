//
// MainTabViewState.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

@available(iOS 15.0, *)
public struct MainTabViewState: Equatable {
    public let selectedTab: Tab
    public let feedBadgeCount: Int
    public let profileBadgeCount: Int
    public let isLoading: Bool
    public let error: String?

    public init(
        selectedTab: Tab = .feed,
        feedBadgeCount: Int = 0,
        profileBadgeCount: Int = 0,
        isLoading: Bool = false,
        error: String? = nil
    ) {
        self.selectedTab = selectedTab
        self.feedBadgeCount = feedBadgeCount
        self.profileBadgeCount = profileBadgeCount
        self.isLoading = isLoading
        self.error = error
    }

    // MARK: - Copy-With Pattern

    public func with(
        selectedTab: Tab? = nil,
        feedBadgeCount: Int? = nil,
        profileBadgeCount: Int? = nil,
        isLoading: Bool? = nil,
        error: String?? = nil
    ) -> Self {
        Self(
            selectedTab: selectedTab ?? self.selectedTab,
            feedBadgeCount: feedBadgeCount ?? self.feedBadgeCount,
            profileBadgeCount: profileBadgeCount ?? self.profileBadgeCount,
            isLoading: isLoading ?? self.isLoading,
            error: error ?? self.error
        )
    }
}
