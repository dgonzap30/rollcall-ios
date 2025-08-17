//
// Restaurant.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

// MARK: - Restaurant Model

@available(iOS 15.0, macOS 12.0, *)
public struct Restaurant: Identifiable, Codable, Equatable, Sendable {
    public let id: RestaurantID
    public let name: String
    public let address: Address
    public let cuisine: CuisineType
    public let priceRange: PriceRange
    public let phoneNumber: String?
    public let website: URL?
    public let coordinates: Coordinates
    public let rating: Double
    public let photoURLs: [URL]
    public let isOmakaseOffered: Bool
    public let createdAt: Date
    public let updatedAt: Date

    public init(
        id: RestaurantID,
        name: String,
        address: Address,
        cuisine: CuisineType,
        priceRange: PriceRange,
        phoneNumber: String?,
        website: URL?,
        coordinates: Coordinates,
        rating: Double,
        photoURLs: [URL],
        isOmakaseOffered: Bool,
        createdAt: Date,
        updatedAt: Date
    ) {
        precondition((1.0...5.0).contains(rating), "Restaurant rating must be between 1.0 and 5.0, got \(rating)")

        self.id = id
        self.name = name
        self.address = address
        self.cuisine = cuisine
        self.priceRange = priceRange
        self.phoneNumber = phoneNumber
        self.website = website
        self.coordinates = coordinates
        self.rating = rating
        self.photoURLs = photoURLs
        self.isOmakaseOffered = isOmakaseOffered
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// MARK: - Restaurant ID

@available(iOS 15.0, macOS 12.0, *)
public struct RestaurantID: Hashable, Codable, Sendable {
    public let value: UUID

    public init() {
        self.value = UUID()
    }

    public init(value: UUID) {
        self.value = value
    }
}

// MARK: - Address

@available(iOS 15.0, macOS 12.0, *)
public struct Address: Codable, Equatable, Sendable {
    public let street: String
    public let city: String
    public let state: String
    public let postalCode: String
    public let country: String

    public init(
        street: String,
        city: String,
        state: String,
        postalCode: String,
        country: String
    ) {
        self.street = street
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
    }

    public var formatted: String {
        "\(self.street), \(self.city), \(self.state) \(self.postalCode), \(self.country)"
    }
}

// MARK: - Coordinates

@available(iOS 15.0, macOS 12.0, *)
public struct Coordinates: Codable, Equatable, Sendable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: - Cuisine Type

@available(iOS 15.0, macOS 12.0, *)
public enum CuisineType: String, Codable, CaseIterable, Sendable {
    case traditional = "Traditional"
    case fusion = "Fusion"
    case kaiseki = "Kaiseki"
    case casual = "Casual"
    case omakase = "Omakase"
}

// MARK: - Price Range

@available(iOS 15.0, macOS 12.0, *)
public enum PriceRange: Int, Codable, CaseIterable, Sendable {
    case budget = 1
    case moderate = 2
    case expensive = 3
    case luxury = 4

    public var displaySymbol: String {
        String(repeating: "$", count: rawValue)
    }
}
