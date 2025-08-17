//
// RollCoreTests.swift
// RollCallTests
//
// Created for RollCall on 13/08/25.
//

@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class RollCoreTests: XCTestCase {
    // MARK: - Setup

    let sampleChefID = ChefID()
    let sampleRestaurantID = RestaurantID()

    // MARK: - Initialization Tests

    func test_roll_init_withAllProperties_shouldCreateRoll() throws {
        let id = RollID()
        let tags = ["delicious", "fresh", "spicy"]
        let photoURL = URL(string: "https://example.com/photo.jpg")
        let createdAt = Date().addingTimeInterval(-3600)
        let updatedAt = Date()

        let roll = try Roll(
            id: id,
            chefID: sampleChefID,
            restaurantID: sampleRestaurantID,
            type: .nigiri,
            name: "Tuna Nigiri",
            description: "Fresh bluefin tuna",
            rating: XCTUnwrap(Rating(value: 5)),
            photoURL: photoURL,
            tags: tags,
            createdAt: createdAt,
            updatedAt: updatedAt
        )

        XCTAssertEqual(roll.id, id)
        XCTAssertEqual(roll.chefID, self.sampleChefID)
        XCTAssertEqual(roll.restaurantID, self.sampleRestaurantID)
        XCTAssertEqual(roll.type, .nigiri)
        XCTAssertEqual(roll.name, "Tuna Nigiri")
        XCTAssertEqual(roll.description, "Fresh bluefin tuna")
        XCTAssertEqual(roll.rating.value, 5)
        XCTAssertEqual(roll.photoURL, photoURL)
        XCTAssertEqual(roll.tags, tags)
        XCTAssertEqual(roll.createdAt, createdAt)
        XCTAssertEqual(roll.updatedAt, updatedAt)
    }

    func test_roll_init_withMinimalProperties_shouldCreateRoll() throws {
        let roll = try Roll(
            id: RollID(),
            chefID: sampleChefID,
            restaurantID: sampleRestaurantID,
            type: .maki,
            name: "Simple Roll",
            description: "A basic roll",
            rating: XCTUnwrap(Rating(value: 3)),
            photoURL: nil,
            tags: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        XCTAssertEqual(roll.type, .maki)
        XCTAssertEqual(roll.name, "Simple Roll")
        XCTAssertNil(roll.photoURL)
        XCTAssertTrue(roll.tags.isEmpty)
    }

    // MARK: - RollID Tests

    func test_rollID_shouldBeUnique() {
        let id1 = RollID()
        let id2 = RollID()
        XCTAssertNotEqual(id1, id2)
    }

    func test_rollID_withSameValue_shouldBeEqual() {
        let uuid = UUID()
        let id1 = RollID(value: uuid)
        let id2 = RollID(value: uuid)
        XCTAssertEqual(id1, id2)
    }

    func test_rollID_hashable_shouldWork() {
        let id1 = RollID()
        let id2 = RollID()
        let set: Set<RollID> = [id1, id2]
        XCTAssertEqual(set.count, 2)
    }

    // MARK: - Rating Tests

    func test_rating_validValues_shouldCreate() throws {
        for value in 1...5 {
            let rating = try XCTUnwrap(Rating(value: value))
            XCTAssertEqual(rating.value, value)
        }
    }

    func test_rating_invalidValues_shouldReturnNil() {
        let invalidValues = [0, 6, -1, 10]
        for value in invalidValues {
            let rating = Rating(value: value)
            XCTAssertNil(rating, "Rating with value \(value) should be nil")
        }
    }

    func test_rating_defaultValue_shouldBe3() {
        XCTAssertEqual(Rating.default.value, 3)
    }

    func test_rating_comparison_shouldWork() throws {
        let rating1 = try XCTUnwrap(Rating(value: 1))
        let rating2 = try XCTUnwrap(Rating(value: 3))
        let rating5 = try XCTUnwrap(Rating(value: 5))

        XCTAssertLessThan(rating1.value, rating2.value)
        XCTAssertLessThan(rating2.value, rating5.value)
        XCTAssertGreaterThan(rating5.value, rating1.value)
    }

    func test_rating_equatable_shouldWork() throws {
        let rating1 = try XCTUnwrap(Rating(value: 4))
        let rating2 = try XCTUnwrap(Rating(value: 4))
        let rating3 = try XCTUnwrap(Rating(value: 2))

        XCTAssertEqual(rating1, rating2)
        XCTAssertNotEqual(rating1, rating3)
    }

    // MARK: - RollType Tests

    func test_rollType_allCases_shouldExist() {
        let expectedCases: [RollType] = [.nigiri, .sashimi, .maki, .uramaki, .temaki, .omakase, .other]
        XCTAssertEqual(RollType.allCases.count, 7)
        XCTAssertEqual(Set(RollType.allCases), Set(expectedCases))
    }

    func test_rollType_rawValues_shouldBeCorrect() {
        XCTAssertEqual(RollType.nigiri.rawValue, "nigiri")
        XCTAssertEqual(RollType.sashimi.rawValue, "sashimi")
        XCTAssertEqual(RollType.maki.rawValue, "maki")
        XCTAssertEqual(RollType.uramaki.rawValue, "uramaki")
        XCTAssertEqual(RollType.temaki.rawValue, "temaki")
        XCTAssertEqual(RollType.omakase.rawValue, "omakase")
        XCTAssertEqual(RollType.other.rawValue, "other")
    }

    func test_rollType_displayName_shouldReturnCorrectString() {
        XCTAssertEqual(RollType.nigiri.displayName, "Nigiri")
        XCTAssertEqual(RollType.sashimi.displayName, "Sashimi")
        XCTAssertEqual(RollType.maki.displayName, "Maki")
        XCTAssertEqual(RollType.uramaki.displayName, "Uramaki")
        XCTAssertEqual(RollType.temaki.displayName, "Temaki")
        XCTAssertEqual(RollType.omakase.displayName, "Omakase")
        XCTAssertEqual(RollType.other.displayName, "Other")
    }

    // MARK: - Equatable Tests

    func test_roll_equality_shouldCompareByID() throws {
        let id = RollID()
        let rating = try XCTUnwrap(Rating(value: 4))

        let roll1 = Roll(
            id: id,
            chefID: sampleChefID,
            restaurantID: sampleRestaurantID,
            type: .nigiri,
            name: "Roll 1",
            description: "Description 1",
            rating: rating,
            photoURL: nil,
            tags: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        let roll2 = Roll(
            id: id,
            chefID: ChefID(), // Different chef
            restaurantID: RestaurantID(), // Different restaurant
            type: .maki, // Different type
            name: "Roll 2", // Different name
            description: "Description 2", // Different description
            rating: rating,
            photoURL: nil,
            tags: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        XCTAssertEqual(roll1, roll2) // Equal because same ID
    }

    func test_roll_inequality_withDifferentIDs() throws {
        let rating = try XCTUnwrap(Rating(value: 4))

        let roll1 = Roll(
            id: RollID(),
            chefID: sampleChefID,
            restaurantID: sampleRestaurantID,
            type: .nigiri,
            name: "Same Name",
            description: "Same Description",
            rating: rating,
            photoURL: nil,
            tags: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        let roll2 = Roll(
            id: RollID(),
            chefID: sampleChefID,
            restaurantID: sampleRestaurantID,
            type: .nigiri,
            name: "Same Name",
            description: "Same Description",
            rating: rating,
            photoURL: nil,
            tags: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        XCTAssertNotEqual(roll1, roll2) // Different IDs
    }

    // MARK: - Hashable Tests

    func test_roll_hashable_shouldHashByID() throws {
        let id = RollID()
        let rating = try XCTUnwrap(Rating(value: 4))

        let roll1 = Roll(
            id: id,
            chefID: sampleChefID,
            restaurantID: sampleRestaurantID,
            type: .nigiri,
            name: "Name 1",
            description: "Description 1",
            rating: rating,
            photoURL: nil,
            tags: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        let roll2 = Roll(
            id: id,
            chefID: ChefID(),
            restaurantID: RestaurantID(),
            type: .maki,
            name: "Name 2",
            description: "Description 2",
            rating: rating,
            photoURL: nil,
            tags: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        XCTAssertEqual(roll1.id.hashValue, roll2.id.hashValue)
    }

    func test_roll_inSet_shouldDeduplicateByID() throws {
        let id = RollID()
        let rating = try XCTUnwrap(Rating(value: 4))

        let roll1 = self.createRoll(with: id, name: "Name 1", rating: rating)
        let roll2 = self.createRoll(with: id, name: "Name 2", rating: rating)
        let roll3 = self.createRoll(with: RollID(), name: "Name 3", rating: rating)

        // Note: Roll doesn't conform to Hashable, so we test ID uniqueness instead
        let rollIDs = Set([roll1.id, roll2.id, roll3.id])
        XCTAssertEqual(rollIDs.count, 2) // roll1 and roll2 have the same ID
    }

    // MARK: - Helper Methods

    private func createRoll(with id: RollID, name: String, rating: Rating) -> Roll {
        Roll(
            id: id,
            chefID: self.sampleChefID,
            restaurantID: self.sampleRestaurantID,
            type: .nigiri,
            name: name,
            description: "Test description",
            rating: rating,
            photoURL: nil,
            tags: [],
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
