//
// FeedViewState.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Foundation

@available(iOS 15.0, *)
public struct FeedViewState: Equatable {
    public let rolls: [RollCardViewState]
    public let isLoading: Bool
    public let isRefreshing: Bool
    public let error: String?
    public let hasMoreContent: Bool
    public let emptyStateMessage: String?

    public init(
        rolls: [RollCardViewState] = [],
        isLoading: Bool = false,
        isRefreshing: Bool = false,
        error: String? = nil,
        hasMoreContent: Bool = true,
        emptyStateMessage: String? = nil
    ) {
        self.rolls = rolls
        self.isLoading = isLoading
        self.isRefreshing = isRefreshing
        self.error = error
        self.hasMoreContent = hasMoreContent
        self.emptyStateMessage = emptyStateMessage
    }

    public static let initial = Self(isLoading: true)

    public static let empty = Self(
        rolls: [],
        isLoading: false,
        hasMoreContent: false,
        emptyStateMessage: "No rolls yet! Be the first to share your sushi experience 🍣"
    )
}

@available(iOS 15.0, *)
public struct RollCardViewState: Identifiable, Equatable {
    public let id: String
    public let chefName: String
    public let chefAvatarURL: URL?
    public let restaurantName: String
    public let rollName: String
    public let rollType: String
    public let rating: Int
    public let description: String?
    public let photoURL: URL?
    public let timeAgo: String
    public let tags: [String]

    public init(
        id: String,
        chefName: String,
        chefAvatarURL: URL? = nil,
        restaurantName: String,
        rollName: String,
        rollType: String,
        rating: Int,
        description: String? = nil,
        photoURL: URL? = nil,
        timeAgo: String,
        tags: [String] = []
    ) {
        self.id = id
        self.chefName = chefName
        self.chefAvatarURL = chefAvatarURL
        self.restaurantName = restaurantName
        self.rollName = rollName
        self.rollType = rollType
        self.rating = rating
        self.description = description
        self.photoURL = photoURL
        self.timeAgo = timeAgo
        self.tags = tags
    }
}
