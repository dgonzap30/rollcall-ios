//
// CoreDataRestaurantRepositoryTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import CoreData
@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class CoreDataRestaurantRepositoryTests: XCTestCase {
    var coreDataStack: CoreDataStack!
    var sut: CoreDataRestaurantRepository!

    override func setUp() async throws {
        try await super.setUp()
        self.coreDataStack = CoreDataStack.makeTestStack()
        self.sut = CoreDataRestaurantRepository(coreDataStack: self.coreDataStack)
    }

    override func tearDown() async throws {
        try await self.coreDataStack.deleteAllData()
        self.sut = nil
        self.coreDataStack = nil
        try await super.tearDown()
    }

    // MARK: - Create Restaurant Tests

    func test_createRestaurant_savesAllProperties() async throws {
        let restaurant = self.makeTestRestaurant()

        let created = try await sut.createRestaurant(restaurant)

        XCTAssertEqual(created.id, restaurant.id)
        XCTAssertEqual(created.name, restaurant.name)
        XCTAssertEqual(created.cuisine, restaurant.cuisine)
        XCTAssertEqual(created.priceRange, restaurant.priceRange)
        XCTAssertEqual(created.address.street, restaurant.address.street)
        XCTAssertEqual(created.phoneNumber, restaurant.phoneNumber)
        XCTAssertEqual(created.website, restaurant.website)
        XCTAssertEqual(created.coordinates.latitude, restaurant.coordinates.latitude)
        XCTAssertEqual(created.rating, restaurant.rating)
        XCTAssertEqual(created.isOmakaseOffered, restaurant.isOmakaseOffered)
    }

    func test_createRestaurant_withMinimalData_saves() async throws {
        let restaurant = Restaurant(
            id: RestaurantID(),
            name: "Minimal Restaurant",
            address: Address(
                street: "Unknown",
                city: "Unknown",
                state: "Unknown",
                postalCode: "00000",
                country: "Unknown"
            ),
            cuisine: .casual,
            priceRange: .moderate,
            phoneNumber: nil,
            website: nil,
            coordinates: Coordinates(latitude: 0.0, longitude: 0.0),
            rating: 0.0,
            photoURLs: [],
            isOmakaseOffered: false,
            createdAt: Date(),
            updatedAt: Date()
        )

        let created = try await sut.createRestaurant(restaurant)

        XCTAssertEqual(created.name, "Minimal Restaurant")
        XCTAssertEqual(created.address.city, "Unknown")
        XCTAssertNil(created.phoneNumber)
        XCTAssertEqual(created.coordinates.latitude, 0.0)
    }

    // MARK: - Fetch All Tests

    func test_fetchAllRestaurants_returnsSortedByName() async throws {
        let restaurant1 = self.makeTestRestaurant(name: "Zebra Sushi")
        let restaurant2 = self.makeTestRestaurant(name: "Arigato Sushi")
        let restaurant3 = self.makeTestRestaurant(name: "Maki Palace")

        _ = try await self.sut.createRestaurant(restaurant1)
        _ = try await self.sut.createRestaurant(restaurant2)
        _ = try await self.sut.createRestaurant(restaurant3)

        let restaurants = try await sut.fetchAllRestaurants()

        XCTAssertEqual(restaurants.count, 3)
        XCTAssertEqual(restaurants[0].name, "Arigato Sushi")
        XCTAssertEqual(restaurants[1].name, "Maki Palace")
        XCTAssertEqual(restaurants[2].name, "Zebra Sushi")
    }

    func test_fetchAllRestaurants_whenEmpty_returnsEmptyArray() async throws {
        let restaurants = try await sut.fetchAllRestaurants()

        XCTAssertTrue(restaurants.isEmpty)
    }

    // MARK: - Fetch by ID Tests

    func test_fetchRestaurant_byId_returnsCorrectRestaurant() async throws {
        let restaurant = self.makeTestRestaurant()
        _ = try await self.sut.createRestaurant(restaurant)

        let fetched = try await sut.fetchRestaurant(by: restaurant.id)

        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.id, restaurant.id)
        XCTAssertEqual(fetched?.name, restaurant.name)
    }

    func test_fetchRestaurant_withInvalidId_returnsNil() async throws {
        let invalidId = RestaurantID()

        let fetched = try await sut.fetchRestaurant(by: invalidId)

        XCTAssertNil(fetched)
    }

    // MARK: - Search Tests

    func test_searchRestaurants_byName_findsMatches() async throws {
        let restaurant1 = self.makeTestRestaurant(name: "Nobu Tokyo")
        let restaurant2 = self.makeTestRestaurant(name: "Tokyo Sushi Bar")
        let restaurant3 = self.makeTestRestaurant(name: "Kyoto Kitchen")

        _ = try await self.sut.createRestaurant(restaurant1)
        _ = try await self.sut.createRestaurant(restaurant2)
        _ = try await self.sut.createRestaurant(restaurant3)

        let results = try await sut.searchRestaurants(query: "Tokyo")

        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.allSatisfy { $0.name.contains("Tokyo") })
    }

    func test_searchRestaurants_caseInsensitive() async throws {
        let restaurant = self.makeTestRestaurant(name: "SUSHI MASTER")
        _ = try await self.sut.createRestaurant(restaurant)

        let results = try await sut.searchRestaurants(query: "sushi")

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results[0].name, "SUSHI MASTER")
    }

    func test_searchRestaurants_byLocation_findsMatches() async throws {
        let address1 = Address(
            street: "123 Main St",
            city: "New York",
            state: "NY",
            postalCode: "10001",
            country: "USA"
        )
        let address2 = Address(
            street: "456 Broadway",
            city: "Los Angeles",
            state: "CA",
            postalCode: "90001",
            country: "USA"
        )

        let restaurant1 = self.makeTestRestaurant(name: "NYC Sushi", address: address1)
        let restaurant2 = self.makeTestRestaurant(name: "LA Rolls", address: address2)
        let restaurant3 = self.makeTestRestaurant(name: "NY Deli", address: address1)

        _ = try await self.sut.createRestaurant(restaurant1)
        _ = try await self.sut.createRestaurant(restaurant2)
        _ = try await self.sut.createRestaurant(restaurant3)

        let results = try await sut.searchRestaurants(query: "New York")

        XCTAssertEqual(results.count, 2)
        XCTAssertTrue(results.allSatisfy { $0.address.city == "New York" })
    }

    func test_searchRestaurants_emptyQuery_returnsAll() async throws {
        let restaurant1 = self.makeTestRestaurant(name: "Restaurant 1")
        let restaurant2 = self.makeTestRestaurant(name: "Restaurant 2")

        _ = try await self.sut.createRestaurant(restaurant1)
        _ = try await self.sut.createRestaurant(restaurant2)

        let results = try await sut.searchRestaurants(query: "")

        XCTAssertEqual(results.count, 2)
    }

    func test_search_byName_returnsMatchingSorted() async throws {
        // Given
        let restaurant1 = self.makeTestRestaurant(name: "Zen Sushi")
        let restaurant2 = self.makeTestRestaurant(name: "Awesome Sushi")
        let restaurant3 = self.makeTestRestaurant(name: "Maki Place")

        _ = try await self.sut.createRestaurant(restaurant1)
        _ = try await self.sut.createRestaurant(restaurant2)
        _ = try await self.sut.createRestaurant(restaurant3)

        // When
        let results = try await sut.searchRestaurants(query: "Sushi")

        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].name, "Awesome Sushi") // Sorted by name
        XCTAssertEqual(results[1].name, "Zen Sushi")
    }

    func test_search_empty_returnsAllSorted() async throws {
        // Given
        let restaurant1 = self.makeTestRestaurant(name: "Zebra Sushi")
        let restaurant2 = self.makeTestRestaurant(name: "Alpha Rolls")

        _ = try await self.sut.createRestaurant(restaurant1)
        _ = try await self.sut.createRestaurant(restaurant2)

        // When
        let results = try await sut.searchRestaurants(query: "")

        // Then
        XCTAssertEqual(results.count, 2)
        XCTAssertEqual(results[0].name, "Alpha Rolls")
        XCTAssertEqual(results[1].name, "Zebra Sushi")
    }

    // MARK: - Update Tests

    func test_updateRestaurant_updatesAllFields() async throws {
        let restaurant = self.makeTestRestaurant()
        let created = try await sut.createRestaurant(restaurant)

        let updatedRestaurant = Restaurant(
            id: created.id,
            name: "Updated Name",
            address: restaurant.address,
            cuisine: .fusion,
            priceRange: .luxury,
            phoneNumber: restaurant.phoneNumber,
            website: restaurant.website,
            coordinates: restaurant.coordinates,
            rating: 4.9,
            photoURLs: restaurant.photoURLs,
            isOmakaseOffered: restaurant.isOmakaseOffered,
            createdAt: restaurant.createdAt,
            updatedAt: Date()
        )

        let updated = try await sut.updateRestaurant(updatedRestaurant)

        XCTAssertEqual(updated.name, "Updated Name")
        XCTAssertEqual(updated.cuisine, .fusion)
        XCTAssertEqual(updated.priceRange, .luxury)
        XCTAssertEqual(updated.rating, 4.9)
    }

    func test_updateRestaurant_nonExistent_throwsError() async throws {
        let restaurant = self.makeTestRestaurant()

        do {
            _ = try await self.sut.updateRestaurant(restaurant)
            XCTFail("Expected error")
        } catch {
            guard case AppError.notFound = error else {
                XCTFail("Expected notFound error, got \(error)")
                return
            }
        }
    }

    // MARK: - Delete Tests

    // Note: deleteRestaurant is not part of RestaurantRepositoryProtocol
    // These tests are commented out until the protocol is updated

    /*
     func test_deleteRestaurant_removesFromDatabase() async throws {
         let restaurant = makeTestRestaurant()
         _ = try await sut.createRestaurant(restaurant)

         try await sut.deleteRestaurant(by: restaurant.id)

         let fetched = try await sut.fetchRestaurant(by: restaurant.id)
         XCTAssertNil(fetched)
     }

     func test_deleteRestaurant_nonExistent_doesNotThrow() async throws {
         let invalidId = RestaurantID()

         // Should not throw
         try await sut.deleteRestaurant(by: invalidId)
     }
     */

    // MARK: - Concurrent Operations Tests

    func test_concurrentCreates_handledSafely() async throws {
        let restaurant1 = self.makeTestRestaurant(name: "Concurrent 1")
        let restaurant2 = self.makeTestRestaurant(name: "Concurrent 2")
        let restaurant3 = self.makeTestRestaurant(name: "Concurrent 3")

        async let create1 = self.sut.createRestaurant(restaurant1)
        async let create2 = self.sut.createRestaurant(restaurant2)
        async let create3 = self.sut.createRestaurant(restaurant3)

        let results = try await [create1, create2, create3]

        XCTAssertEqual(results.count, 3)

        let allRestaurants = try await sut.fetchAllRestaurants()
        XCTAssertEqual(allRestaurants.count, 3)
    }

    // MARK: - Helper Methods

    private func makeTestRestaurant(
        name: String = "Test Restaurant",
        address: Address? = nil
    ) -> Restaurant {
        Restaurant(
            id: RestaurantID(),
            name: name,
            address: address ?? Address(
                street: "123 Test St",
                city: "Test City",
                state: "TS",
                postalCode: "12345",
                country: "USA"
            ),
            cuisine: .traditional,
            priceRange: .moderate,
            phoneNumber: "+1 555-0123",
            website: URL(string: "https://test.com"),
            coordinates: Coordinates(
                latitude: 40.7128,
                longitude: -74.0060
            ),
            rating: 4.5,
            photoURLs: [],
            isOmakaseOffered: true,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
