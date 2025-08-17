//
// FeedTestUtilities.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Foundation
@testable import RollCall
import XCTest

@available(iOS 15.0, *)
struct FeedTestUtilities {
    // MARK: - Test Data Container

    struct TestData {
        let rolls: [Roll]
        let chefs: [Chef]
        let restaurants: [Restaurant]
    }

    // MARK: - Static Test Data Creation

    static func createTestData(rollCount: Int = 3) -> TestData {
        let rolls = self.createSampleRolls(count: rollCount)
        let chefs = [createSampleChef()]
        let restaurants = self.createSampleRestaurants(count: 2)
        return TestData(rolls: rolls, chefs: chefs, restaurants: restaurants)
    }

    static func createLargeTestData(rollCount: Int) -> TestData {
        let rolls = self.createSampleRolls(count: rollCount)
        let chefs = [createSampleChef()]
        let restaurants = self.createSampleRestaurants(count: 5)
        return TestData(rolls: rolls, chefs: chefs, restaurants: restaurants)
    }

    static func createSampleRollCard() -> RollCardViewState {
        let roll = self.createSampleRoll()
        let chef = self.createSampleChef()
        let restaurant = self.createSampleRestaurant()

        return RollCardViewState(
            id: roll.id.value.uuidString,
            chefName: chef.displayName,
            chefAvatarURL: chef.avatarURL,
            restaurantName: restaurant.name,
            rollName: roll.name,
            rollType: roll.type.displayName,
            rating: roll.rating.value,
            description: roll.description,
            photoURL: roll.photoURL,
            timeAgo: "2h ago",
            tags: roll.tags
        )
    }

    static func createSampleRoll() -> Roll {
        Roll(
            id: RollID(),
            chefID: ChefID(),
            restaurantID: RestaurantID(),
            type: .nigiri,
            name: "Sample Roll",
            description: "Sample description",
            rating: Rating(value: 4)!,
            photoURL: nil,
            tags: ["sample"],
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    static func createSampleRolls(count: Int) -> [Roll] {
        (0..<count).map { index in
            Roll(
                id: RollID(),
                chefID: ChefID(),
                restaurantID: RestaurantID(),
                type: RollType.allCases.randomElement()!,
                name: "Roll \(index)",
                description: "Description \(index)",
                rating: Rating(value: Int.random(in: 3...5))!,
                photoURL: nil,
                tags: ["tag\(index)"],
                createdAt: Date().addingTimeInterval(Double(-index * 3600)),
                updatedAt: Date()
            )
        }
    }

    static func createSampleChef() -> Chef {
        Chef(
            id: ChefID(),
            username: "testchef",
            displayName: "Test Chef",
            email: "test@example.com",
            bio: "Test bio",
            avatarURL: nil,
            favoriteRollType: .nigiri,
            rollCount: 10,
            joinedAt: Date(),
            lastActiveAt: Date()
        )
    }

    static func createSampleRestaurant() -> Restaurant {
        Restaurant(
            id: RestaurantID(),
            name: "Test Restaurant",
            address: Address(
                street: "123 Test St",
                city: "Test City",
                state: "TS",
                postalCode: "12345",
                country: "Test Country"
            ),
            cuisine: .traditional,
            priceRange: .moderate,
            phoneNumber: nil,
            website: nil,
            coordinates: Coordinates(latitude: 0, longitude: 0),
            rating: 4.5,
            photoURLs: [],
            isOmakaseOffered: true,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    static func createSampleRestaurants(count: Int) -> [Restaurant] {
        (0..<count).map { index in
            Restaurant(
                id: RestaurantID(),
                name: "Restaurant \(index)",
                address: Address(
                    street: "\(100 + index) Test St",
                    city: "Test City",
                    state: "TS",
                    postalCode: "1234\(index)",
                    country: "Test Country"
                ),
                cuisine: CuisineType.allCases.randomElement()!,
                priceRange: PriceRange.allCases.randomElement()!,
                phoneNumber: nil,
                website: nil,
                coordinates: Coordinates(latitude: Double(index), longitude: Double(index)),
                rating: Double.random(in: 3.0...5.0),
                photoURLs: [],
                isOmakaseOffered: Bool.random(),
                createdAt: Date(),
                updatedAt: Date()
            )
        }
    }
}

@available(iOS 15.0, *)
extension XCTestCase {
    // MARK: - Mock Data Creation

    func createMockRoll() -> Roll {
        Roll(
            id: RollID(),
            chefID: ChefID(),
            restaurantID: RestaurantID(),
            type: .nigiri,
            name: "Test Roll",
            description: "Test description",
            rating: Rating(value: 4)!,
            photoURL: nil,
            tags: ["test"],
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    func createMockRolls(count: Int) -> [Roll] {
        (0..<count).map { index in
            Roll(
                id: RollID(),
                chefID: ChefID(),
                restaurantID: RestaurantID(),
                type: RollType.allCases.randomElement()!,
                name: "Roll \(index)",
                description: "Description \(index)",
                rating: Rating(value: Int.random(in: 3...5))!,
                photoURL: nil,
                tags: ["tag\(index)"],
                createdAt: Date().addingTimeInterval(Double(-index * 3600)),
                updatedAt: Date()
            )
        }
    }

    func createMockChef() -> Chef {
        Chef(
            id: ChefID(),
            username: "testchef",
            displayName: "Test Chef",
            email: "test@example.com",
            bio: "Test bio",
            avatarURL: nil,
            favoriteRollType: .nigiri,
            rollCount: 10,
            joinedAt: Date(),
            lastActiveAt: Date()
        )
    }

    func createMockRestaurant() -> Restaurant {
        Restaurant(
            id: RestaurantID(),
            name: "Test Restaurant",
            address: Address(
                street: "123 Test St",
                city: "Test City",
                state: "TS",
                postalCode: "12345",
                country: "Test Country"
            ),
            cuisine: .traditional,
            priceRange: .moderate,
            phoneNumber: nil,
            website: nil,
            coordinates: Coordinates(latitude: 0, longitude: 0),
            rating: 4.5,
            photoURLs: [],
            isOmakaseOffered: true,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
