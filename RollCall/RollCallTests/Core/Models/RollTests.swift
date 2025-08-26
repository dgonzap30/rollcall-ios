//
// RollTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 22/07/25.
//

@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class RollTests: XCTestCase {
    // MARK: - Initialization Tests

    func test_init_withAllProperties_createsRoll() {
        let rollId = RollID()
        let chefId = ChefID()
        let restaurantId = RestaurantID()
        let photoURL = URL(string: "https://example.com/roll.jpg")!
        let tags = ["salmon", "fresh", "delicious"]
        let createdAt = Date().addingTimeInterval(-3600)
        let updatedAt = Date()

        let roll = Roll(
            id: rollId,
            chefID: chefId,
            restaurantID: restaurantId,
            type: .nigiri,
            name: "Salmon Nigiri",
            description: "Fresh Atlantic salmon",
            rating: Rating(value: 5)!,
            photoURL: photoURL,
            tags: tags,
            createdAt: createdAt,
            updatedAt: updatedAt
        )

        XCTAssertEqual(roll.id, rollId)
        XCTAssertEqual(roll.chefID, chefId)
        XCTAssertEqual(roll.restaurantID, restaurantId)
        XCTAssertEqual(roll.type, .nigiri)
        XCTAssertEqual(roll.name, "Salmon Nigiri")
        XCTAssertEqual(roll.description, "Fresh Atlantic salmon")
        XCTAssertEqual(roll.rating.value, 5)
        XCTAssertEqual(roll.photoURL, photoURL)
        XCTAssertEqual(roll.tags, tags)
        XCTAssertEqual(roll.createdAt, createdAt)
        XCTAssertEqual(roll.updatedAt, updatedAt)
    }

    func test_init_withOptionalNilValues_createsRoll() {
        let roll = Roll(
            id: RollID(),
            chefID: ChefID(),
            restaurantID: RestaurantID(),
            type: .maki,
            name: "Simple Roll",
            description: nil,
            rating: Rating(value: 3)!,
            photoURL: nil,
            tags: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        XCTAssertNil(roll.description)
        XCTAssertNil(roll.photoURL)
        XCTAssertTrue(roll.tags.isEmpty)
    }

    // MARK: - RollID Tests

    func test_rollID_uniqueness() {
        let id1 = RollID()
        let id2 = RollID()

        XCTAssertNotEqual(id1.value, id2.value)
        XCTAssertNotEqual(id1, id2)
    }

    func test_rollID_initWithValue() {
        let uuid = UUID()
        let id = RollID(value: uuid)

        XCTAssertEqual(id.value, uuid)
    }

    // MARK: - Rating Tests

    func test_rating_validRange() {
        XCTAssertNotNil(Rating(value: 1))
        XCTAssertNotNil(Rating(value: 2))
        XCTAssertNotNil(Rating(value: 3))
        XCTAssertNotNil(Rating(value: 4))
        XCTAssertNotNil(Rating(value: 5))

        XCTAssertEqual(Rating(value: 1)?.value, 1)
        XCTAssertEqual(Rating(value: 5)?.value, 5)
    }

    func test_rating_invalidRange() {
        XCTAssertNil(Rating(value: 0))
        XCTAssertNil(Rating(value: 6))
        XCTAssertNil(Rating(value: -1))
        XCTAssertNil(Rating(value: 100))
    }

    func test_rating_staticProperties() {
        XCTAssertEqual(Rating.minimum.value, 1)
        XCTAssertEqual(Rating.maximum.value, 5)
        XCTAssertEqual(Rating.default.value, 3)
    }

    func test_rating_equatable() {
        let rating1 = Rating(value: 4)!
        let rating2 = Rating(value: 4)!
        let rating3 = Rating(value: 5)!

        XCTAssertEqual(rating1, rating2)
        XCTAssertNotEqual(rating1, rating3)
    }

    // MARK: - RollType Tests

    func test_rollType_allCases() {
        let allCases = RollType.allCases

        XCTAssertEqual(allCases.count, 7)
        XCTAssertTrue(allCases.contains(.nigiri))
        XCTAssertTrue(allCases.contains(.maki))
        XCTAssertTrue(allCases.contains(.sashimi))
        XCTAssertTrue(allCases.contains(.temaki))
        XCTAssertTrue(allCases.contains(.uramaki))
        XCTAssertTrue(allCases.contains(.omakase))
        XCTAssertTrue(allCases.contains(.other))
    }

    func test_rollType_displayName() {
        XCTAssertEqual(RollType.nigiri.displayName, "Nigiri")
        XCTAssertEqual(RollType.maki.displayName, "Maki")
        XCTAssertEqual(RollType.sashimi.displayName, "Sashimi")
        XCTAssertEqual(RollType.temaki.displayName, "Temaki")
        XCTAssertEqual(RollType.uramaki.displayName, "Uramaki")
        XCTAssertEqual(RollType.omakase.displayName, "Omakase")
        XCTAssertEqual(RollType.other.displayName, "Other")
    }

    // MARK: - Relationships Tests

    func test_roll_hasRequiredRelationships() {
        let chefId = ChefID()
        let restaurantId = RestaurantID()

        let roll = Roll(
            id: RollID(),
            chefID: chefId,
            restaurantID: restaurantId,
            type: .nigiri,
            name: "Test Roll",
            description: nil,
            rating: Rating(value: 4)!,
            photoURL: nil,
            tags: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        XCTAssertEqual(roll.chefID, chefId)
        XCTAssertEqual(roll.restaurantID, restaurantId)
    }
}
