//
// SampleData.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

@available(iOS 15.0, *)
public enum SampleData {
    // MARK: - Sample Restaurants

    public static func createSampleRestaurants() -> [Restaurant] {
        [
            self.createSushiYasuda(),
            self.createNobu(),
            self.createKatsuya()
        ]
    }

    private static func createSushiYasuda() -> Restaurant {
        Restaurant(
            id: RestaurantID(),
            name: "Sushi Yasuda",
            address: Address(
                street: "204 E 43rd St",
                city: "New York",
                state: "NY",
                postalCode: "10017",
                country: "USA"
            ),
            cuisine: .traditional,
            priceRange: .expensive,
            phoneNumber: "+1 212-972-1001",
            website: URL(string: "https://sushiyasuda.com"),
            coordinates: Coordinates(
                latitude: 40.7516,
                longitude: -73.9755
            ),
            rating: 4.8,
            photoURLs: [],
            isOmakaseOffered: true,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    private static func createNobu() -> Restaurant {
        Restaurant(
            id: RestaurantID(),
            name: "Nobu",
            address: Address(
                street: "195 Broadway",
                city: "New York",
                state: "NY",
                postalCode: "10007",
                country: "USA"
            ),
            cuisine: .fusion,
            priceRange: .luxury,
            phoneNumber: "+1 212-219-0500",
            website: URL(string: "https://noburestaurants.com"),
            coordinates: Coordinates(
                latitude: 40.7107,
                longitude: -74.0093
            ),
            rating: 4.6,
            photoURLs: [],
            isOmakaseOffered: true,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    private static func createKatsuya() -> Restaurant {
        Restaurant(
            id: RestaurantID(),
            name: "Katsuya",
            address: Address(
                street: "1050 S Flower St",
                city: "Los Angeles",
                state: "CA",
                postalCode: "90015",
                country: "USA"
            ),
            cuisine: .casual,
            priceRange: .moderate,
            phoneNumber: "+1 213-749-1900",
            website: URL(string: "https://katsuyarestaurant.com"),
            coordinates: Coordinates(
                latitude: 34.0443,
                longitude: -118.2654
            ),
            rating: 4.3,
            photoURLs: [],
            isOmakaseOffered: false,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    // MARK: - Sample Chefs

    public static func createSampleChef() -> Chef {
        Chef(
            id: ChefID(),
            username: "sushilover",
            displayName: "Sushi Lover",
            email: "sushi@example.com",
            bio: "Exploring the world one roll at a time",
            avatarURL: nil,
            favoriteRollType: .nigiri,
            rollCount: 42,
            joinedAt: Date().addingTimeInterval(-86400 * 30),
            lastActiveAt: Date()
        )
    }

    // MARK: - Sample Rolls

    public static func createSampleRolls(chefId: ChefID, restaurantId: RestaurantID) -> [Roll] {
        [
            Roll(
                id: RollID(),
                chefID: chefId,
                restaurantID: restaurantId,
                type: .nigiri,
                name: "Salmon Nigiri",
                description: "Perfect texture and temperature",
                rating: .maximum,
                photoURL: nil,
                tags: ["salmon", "nigiri"],
                createdAt: Date().addingTimeInterval(-3600),
                updatedAt: Date().addingTimeInterval(-3600)
            ),
            Roll(
                id: RollID(),
                chefID: chefId,
                restaurantID: restaurantId,
                type: .maki,
                name: "Spicy Tuna Roll",
                description: "Good spice level",
                rating: Rating(value: 4) ?? .default,
                photoURL: nil,
                tags: ["tuna", "spicy", "maki"],
                createdAt: Date().addingTimeInterval(-7200),
                updatedAt: Date().addingTimeInterval(-7200)
            )
        ]
    }
}
