//
// CoreDataRollRepositoryTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import CoreData
@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class CoreDataRollRepositoryTests: XCTestCase {
    var coreDataStack: CoreDataStack!
    var rollRepository: CoreDataRollRepository!
    var chefRepository: CoreDataChefRepository!
    var restaurantRepository: CoreDataRestaurantRepository!
    var testChef: Chef!
    var testRestaurant: Restaurant!

    override func setUp() async throws {
        try await super.setUp()
        self.coreDataStack = CoreDataStack.makeTestStack()
        self.rollRepository = CoreDataRollRepository(coreDataStack: self.coreDataStack)
        self.chefRepository = CoreDataChefRepository(coreDataStack: self.coreDataStack)
        self.restaurantRepository = CoreDataRestaurantRepository(coreDataStack: self.coreDataStack)

        self.testChef = try await self.createTestChef()
        self.testRestaurant = try await self.createTestRestaurant()
    }

    override func tearDown() async throws {
        try await self.coreDataStack.deleteAllData()
        self.rollRepository = nil
        self.chefRepository = nil
        self.restaurantRepository = nil
        self.coreDataStack = nil
        try await super.tearDown()
    }

    // MARK: - Create Roll Tests

    func test_createRoll_savesRollToDatabase() async throws {
        let roll = self.makeTestRoll()

        let createdRoll = try await rollRepository.createRoll(roll)

        XCTAssertEqual(createdRoll.id, roll.id)
        XCTAssertEqual(createdRoll.name, roll.name)
        XCTAssertEqual(createdRoll.rating.value, roll.rating.value)
    }

    func test_createRoll_throwsWhenChefNotFound() async throws {
        let roll = Roll(
            id: RollID(value: UUID()),
            chefID: ChefID(value: UUID()),
            restaurantID: testRestaurant.id,
            type: .maki,
            name: "Test Roll",
            description: nil,
            rating: Rating(value: 4)!,
            photoURL: nil,
            tags: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        do {
            _ = try await self.rollRepository.createRoll(roll)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is AppError)
        }
    }

    // MARK: - Fetch Roll Tests

    func test_fetchAllRolls_returnsRollsSortedByCreatedDate() async throws {
        let roll1 = self.makeTestRoll(name: "Roll 1", createdAt: Date().addingTimeInterval(-3600))
        let roll2 = self.makeTestRoll(name: "Roll 2", createdAt: Date())
        let roll3 = self.makeTestRoll(name: "Roll 3", createdAt: Date().addingTimeInterval(-7200))

        _ = try await self.rollRepository.createRoll(roll1)
        _ = try await self.rollRepository.createRoll(roll2)
        _ = try await self.rollRepository.createRoll(roll3)

        let rolls = try await rollRepository.fetchAllRolls()

        XCTAssertEqual(rolls.count, 3)
        XCTAssertEqual(rolls[0].name, "Roll 2")
        XCTAssertEqual(rolls[1].name, "Roll 1")
        XCTAssertEqual(rolls[2].name, "Roll 3")
    }

    func test_fetchRoll_returnsRollWhenExists() async throws {
        let roll = self.makeTestRoll()
        _ = try await self.rollRepository.createRoll(roll)

        let fetchedRoll = try await rollRepository.fetchRoll(by: roll.id)

        XCTAssertNotNil(fetchedRoll)
        XCTAssertEqual(fetchedRoll?.id, roll.id)
    }

    func test_fetchRolls_forChef_returnsOnlyChefRolls() async throws {
        let otherChef = try await createTestChef(username: "otherchef", email: "other@example.com")

        let roll1 = self.makeTestRoll(name: "My Roll 1")
        let roll2 = self.makeTestRoll(name: "My Roll 2")
        let otherRoll = self.makeTestRoll(
            name: "Other Chef Roll",
            chefID: otherChef.id
        )

        _ = try await self.rollRepository.createRoll(roll1)
        _ = try await self.rollRepository.createRoll(roll2)
        _ = try await self.rollRepository.createRoll(otherRoll)

        let myRolls = try await rollRepository.fetchRolls(for: self.testChef.id)

        XCTAssertEqual(myRolls.count, 2)
        XCTAssertTrue(myRolls.allSatisfy { $0.chefID == self.testChef.id })
    }

    // MARK: - Update Roll Tests

    func test_updateRoll_updatesExistingRoll() async throws {
        let roll = self.makeTestRoll()
        _ = try await self.rollRepository.createRoll(roll)

        let updatedRoll = Roll(
            id: roll.id,
            chefID: roll.chefID,
            restaurantID: roll.restaurantID,
            type: roll.type,
            name: "Updated Roll",
            description: roll.description,
            rating: Rating(value: 5)!,
            photoURL: roll.photoURL,
            tags: roll.tags,
            createdAt: roll.createdAt,
            updatedAt: Date()
        )

        let result = try await rollRepository.updateRoll(updatedRoll)

        XCTAssertEqual(result.name, "Updated Roll")
        XCTAssertEqual(result.rating.value, 5)
    }

    // MARK: - Delete Roll Tests

    func test_deleteRoll_removesRollFromDatabase() async throws {
        let roll = self.makeTestRoll()
        _ = try await self.rollRepository.createRoll(roll)

        try await self.rollRepository.deleteRoll(by: roll.id)

        let fetchedRoll = try await rollRepository.fetchRoll(by: roll.id)
        XCTAssertNil(fetchedRoll)
    }

    // MARK: - Save Tests (Convenience Method)

    func test_save_success_withNewRoll() async throws {
        // Given
        let roll = self.makeTestRoll(name: "New Sushi Roll")

        // When
        let savedRoll = try await rollRepository.createRoll(roll)

        // Then
        XCTAssertEqual(savedRoll.name, "New Sushi Roll")
        XCTAssertEqual(savedRoll.id, roll.id)

        // Verify it was persisted
        let fetchedRoll = try await rollRepository.fetchRoll(by: roll.id)
        XCTAssertNotNil(fetchedRoll)
        XCTAssertEqual(fetchedRoll?.name, "New Sushi Roll")
    }

    func test_save_duplicate_shouldUpdate() async throws {
        // Given
        let roll = self.makeTestRoll(name: "Original Roll")
        _ = try await self.rollRepository.createRoll(roll)

        // When - Update the same roll
        let updatedRoll = Roll(
            id: roll.id,
            chefID: roll.chefID,
            restaurantID: roll.restaurantID,
            type: .nigiri,
            name: "Updated Nigiri",
            description: "Delicious update",
            rating: Rating(value: 5)!,
            photoURL: nil,
            tags: ["updated", "nigiri"],
            createdAt: roll.createdAt,
            updatedAt: Date()
        )

        let result = try await rollRepository.updateRoll(updatedRoll)

        // Then
        XCTAssertEqual(result.name, "Updated Nigiri")
        XCTAssertEqual(result.type, .nigiri)
        XCTAssertEqual(result.rating.value, 5)
    }

    // MARK: - Helpers

    private func createTestChef(
        username: String = "testchef",
        email: String = "test@example.com"
    ) async throws -> Chef {
        let chef = Chef(
            id: ChefID(value: UUID()),
            username: username,
            displayName: "Test Chef",
            email: email,
            bio: nil,
            avatarURL: nil,
            favoriteRollType: nil,
            rollCount: 0,
            joinedAt: Date(),
            lastActiveAt: Date()
        )
        return try await self.chefRepository.createChef(chef)
    }

    private func createTestRestaurant() async throws -> Restaurant {
        let restaurant = Restaurant(
            id: RestaurantID(value: UUID()),
            name: "Test Restaurant",
            address: Address(
                street: "Unknown",
                city: "Unknown",
                state: "Unknown",
                postalCode: "00000",
                country: "Unknown"
            ),
            cuisine: .traditional,
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
        return try await self.restaurantRepository.createRestaurant(restaurant)
    }

    private func makeTestRoll(
        name: String = "Test Roll",
        chefID: ChefID? = nil,
        createdAt: Date = Date()
    ) -> Roll {
        Roll(
            id: RollID(value: UUID()),
            chefID: chefID ?? self.testChef.id,
            restaurantID: self.testRestaurant.id,
            type: .maki,
            name: name,
            description: "Test description",
            rating: Rating(value: 4)!,
            photoURL: nil,
            tags: ["test"],
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
}
