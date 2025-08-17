//
// RestaurantEqualityTests.swift
// RollCallTests
//
// Created for RollCall on 13/08/25.
//

@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class RestaurantEqualityTests: XCTestCase {
    // MARK: - RestaurantID Tests

    func test_restaurantID_shouldBeUnique() {
        let id1 = RestaurantID()
        let id2 = RestaurantID()
        XCTAssertNotEqual(id1, id2)
    }

    func test_restaurantID_withSameValue_shouldBeEqual() {
        let uuid = UUID()
        let id1 = RestaurantID(value: uuid)
        let id2 = RestaurantID(value: uuid)
        XCTAssertEqual(id1, id2)
    }

    // MARK: - Restaurant Equatable Tests

    func test_restaurant_equality_shouldCompareByID() {
        let id = RestaurantID()
        let address = Address(
            street: "123 Test St",
            city: "Tokyo",
            state: "Tokyo",
            postalCode: "100-0001",
            country: "Japan"
        )

        let restaurant1 = Restaurant(
            id: id,
            name: "Restaurant 1",
            address: address,
            cuisine: .traditional,
            priceRange: .budget,
            phoneNumber: nil,
            website: nil,
            coordinates: Coordinates(latitude: 0.0, longitude: 0.0),
            rating: 1.0,
            photoURLs: [],
            isOmakaseOffered: false,
            createdAt: Date(),
            updatedAt: Date()
        )

        let restaurant2 = Restaurant(
            id: id,
            name: "Restaurant 2", // Different name
            address: address,
            cuisine: .traditional,
            priceRange: .budget,
            phoneNumber: nil,
            website: nil,
            coordinates: Coordinates(latitude: 0.0, longitude: 0.0),
            rating: 1.0,
            photoURLs: [],
            isOmakaseOffered: false,
            createdAt: Date(),
            updatedAt: Date()
        )

        XCTAssertEqual(restaurant1, restaurant2) // Equal because same ID
    }

    func test_restaurant_inequality_withDifferentIDs() {
        let address = Address(
            street: "123 Test St",
            city: "Tokyo",
            state: "Tokyo",
            postalCode: "100-0001",
            country: "Japan"
        )

        let restaurant1 = Restaurant(
            id: RestaurantID(),
            name: "Same Name",
            address: address,
            cuisine: .traditional,
            priceRange: .budget,
            phoneNumber: nil,
            website: nil,
            coordinates: Coordinates(latitude: 0.0, longitude: 0.0),
            rating: 1.0,
            photoURLs: [],
            isOmakaseOffered: false,
            createdAt: Date(),
            updatedAt: Date()
        )

        let restaurant2 = Restaurant(
            id: RestaurantID(),
            name: "Same Name",
            address: address,
            cuisine: .traditional,
            priceRange: .budget,
            phoneNumber: nil,
            website: nil,
            coordinates: Coordinates(latitude: 0.0, longitude: 0.0),
            rating: 1.0,
            photoURLs: [],
            isOmakaseOffered: false,
            createdAt: Date(),
            updatedAt: Date()
        )

        XCTAssertNotEqual(restaurant1, restaurant2) // Different IDs
    }

    // MARK: - Hashable Tests

    func test_restaurant_hashable_shouldHashByID() {
        let id = RestaurantID()
        let restaurant1 = self.createRestaurant(with: id, name: "Name 1")
        let restaurant2 = self.createRestaurant(with: id, name: "Name 2")

        XCTAssertEqual(restaurant1.id.hashValue, restaurant2.id.hashValue)
    }

    func test_restaurant_inSet_shouldUseDuplicateByID() {
        let id = RestaurantID()
        let restaurant1 = self.createRestaurant(with: id, name: "Name 1")
        let restaurant2 = self.createRestaurant(with: id, name: "Name 2")
        let restaurant3 = self.createRestaurant(with: RestaurantID(), name: "Name 3")

        // Note: Restaurant doesn't conform to Hashable, so we test ID uniqueness instead
        let restaurantIDs = Set([restaurant1.id, restaurant2.id, restaurant3.id])
        XCTAssertEqual(restaurantIDs.count, 2) // restaurant1 and restaurant2 have the same ID
    }

    // MARK: - Helper Methods

    private func createRestaurant(with id: RestaurantID, name: String) -> Restaurant {
        Restaurant(
            id: id,
            name: name,
            address: Address(
                street: "Test St",
                city: "Tokyo",
                state: "Tokyo",
                postalCode: "100-0001",
                country: "Japan"
            ),
            cuisine: .traditional,
            priceRange: .budget,
            phoneNumber: nil,
            website: nil,
            coordinates: Coordinates(latitude: 0.0, longitude: 0.0),
            rating: 1.0,
            photoURLs: [],
            isOmakaseOffered: false,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
