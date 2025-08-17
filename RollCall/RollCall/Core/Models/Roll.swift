//
// Roll.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

// MARK: - Roll Model

@available(iOS 15.0, macOS 12.0, *)
public struct Roll: Identifiable, Codable, Equatable, Sendable {
    public let id: RollID
    public let chefID: ChefID
    public let restaurantID: RestaurantID
    public let type: RollType
    public let name: String
    public let description: String?
    public let rating: Rating
    public let photoURL: URL?
    public let tags: [String]
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: RollID,
        chefID: ChefID,
        restaurantID: RestaurantID,
        type: RollType,
        name: String,
        description: String?,
        rating: Rating,
        photoURL: URL?,
        tags: [String],
        createdAt: Date,
        updatedAt: Date
    ) {
        self.id = id
        self.chefID = chefID
        self.restaurantID = restaurantID
        self.type = type
        self.name = name
        self.description = description
        self.rating = rating
        self.photoURL = photoURL
        self.tags = tags
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Strong Type IDs

@available(iOS 15.0, macOS 12.0, *)
public struct RollID: Hashable, Codable, Sendable {
    public let value: UUID

    public init() {
        self.value = UUID()
    }

    public init(value: UUID) {
        self.value = value
    }
}

// MARK: - Roll Type

@available(iOS 15.0, macOS 12.0, *)
public enum RollType: String, Codable, CaseIterable, Sendable {
    case nigiri
    case maki
    case sashimi
    case temaki
    case uramaki
    case omakase
    case other

    public var displayName: String {
        switch self {
        case .nigiri: "Nigiri"
        case .maki: "Maki"
        case .sashimi: "Sashimi"
        case .temaki: "Temaki"
        case .uramaki: "Uramaki"
        case .omakase: "Omakase"
        case .other: "Other"
        }
    }
}

// MARK: - Rating

@available(iOS 15.0, macOS 12.0, *)
public struct Rating: Codable, Equatable, Sendable {
    public let value: Int

    public init?(value: Int) {
        guard (1...5).contains(value) else { return nil }
        self.value = value
    }

    // These are guaranteed safe as the values are within the valid range (1...5)
    public static let minimum: Rating = {
        guard let rating = Self(value: 1) else {
            fatalError("Rating.minimum initialization failed - this should never happen")
        }
        return rating
    }()

    public static let maximum: Rating = {
        guard let rating = Self(value: 5) else {
            fatalError("Rating.maximum initialization failed - this should never happen")
        }
        return rating
    }()

    public static let `default`: Rating = {
        guard let rating = Self(value: 3) else {
            fatalError("Rating.default initialization failed - this should never happen")
        }
        return rating
    }()
}
