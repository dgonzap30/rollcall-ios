//
// Chef.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

// MARK: - Chef Model

@available(iOS 15.0, macOS 12.0, *)
public struct Chef: Identifiable, Codable, Equatable, Sendable {
    public let id: ChefID
    public let username: String
    public let displayName: String
    public let email: String
    public let bio: String?
    public let avatarURL: URL?
    public let favoriteRollType: RollType?
    public let rollCount: Int
    public let joinedAt: Date
    public let lastActiveAt: Date
}

// MARK: - Chef ID

@available(iOS 15.0, macOS 12.0, *)
public struct ChefID: Hashable, Codable, Sendable {
    public let value: UUID

    public init() {
        self.value = UUID()
    }

    public init(value: UUID) {
        self.value = value
    }
}

// MARK: - Chef Stats

@available(iOS 15.0, macOS 12.0, *)
public struct ChefStats: Codable, Equatable, Sendable {
    public let totalRolls: Int
    public let averageRating: Double
    public let favoriteRestaurant: Restaurant?
    public let streakDays: Int
    public let achievements: [Achievement]
}

// MARK: - Achievement

@available(iOS 15.0, macOS 12.0, *)
public struct Achievement: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let name: String
    public let description: String
    public let iconName: String
    public let unlockedAt: Date
}
