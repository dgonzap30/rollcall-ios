//
// RollCodableTests.swift
// RollCallTests
//
// Created for RollCall on 13/08/25.
//

@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class RollCodableTests: XCTestCase {
    let sampleChefID = ChefID()
    let sampleRestaurantID = RestaurantID()

    // MARK: - Codable Tests

    func test_roll_codable_shouldEncodeAndDecode() throws {
        let original = try Roll(
            id: RollID(),
            chefID: sampleChefID,
            restaurantID: sampleRestaurantID,
            type: .uramaki,
            name: "California Roll",
            description: "Avocado, cucumber, and crab",
            rating: XCTUnwrap(Rating(value: 4)),
            photoURL: URL(string: "https://example.com/california.jpg"),
            tags: ["classic", "california", "avocado"],
            createdAt: Date(),
            updatedAt: Date()
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(Roll.self, from: data)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.chefID, original.chefID)
        XCTAssertEqual(decoded.restaurantID, original.restaurantID)
        XCTAssertEqual(decoded.type, original.type)
        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.description, original.description)
        XCTAssertEqual(decoded.rating, original.rating)
        XCTAssertEqual(decoded.photoURL, original.photoURL)
        XCTAssertEqual(decoded.tags, original.tags)
    }

    func test_roll_codable_withNilPhotoURL_shouldEncodeAndDecode() throws {
        let original = try Roll(
            id: RollID(),
            chefID: sampleChefID,
            restaurantID: sampleRestaurantID,
            type: .sashimi,
            name: "Salmon Sashimi",
            description: "Fresh salmon slices",
            rating: XCTUnwrap(Rating(value: 5)),
            photoURL: nil,
            tags: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(Roll.self, from: data)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertNil(decoded.photoURL)
        XCTAssertTrue(decoded.tags.isEmpty)
    }

    func test_rollID_codable_shouldEncodeAndDecode() throws {
        let original = RollID()

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(RollID.self, from: data)

        XCTAssertEqual(decoded, original)
    }

    func test_rating_codable_shouldEncodeAndDecode() throws {
        for value in 1...5 {
            let original = try XCTUnwrap(Rating(value: value))

            let data = try JSONEncoder().encode(original)
            let decoded = try JSONDecoder().decode(Rating.self, from: data)

            XCTAssertEqual(decoded, original)
        }
    }

    func test_rollType_codable_shouldEncodeAndDecode() throws {
        for rollType in RollType.allCases {
            let data = try JSONEncoder().encode(rollType)
            let decoded = try JSONDecoder().decode(RollType.self, from: data)
            XCTAssertEqual(decoded, rollType)
        }
    }

    func test_roll_withSpecialCharacters_shouldEncode() throws {
        let roll = try Roll(
            id: RollID(),
            chefID: sampleChefID,
            restaurantID: sampleRestaurantID,
            type: .nigiri,
            name: "特上にぎり 🍣",
            description: "最高級の寿司です。新鮮な魚を使用。",
            rating: XCTUnwrap(Rating(value: 5)),
            photoURL: nil,
            tags: ["特上", "高級", "新鮮"],
            createdAt: Date(),
            updatedAt: Date()
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(roll)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Roll.self, from: data)

        XCTAssertEqual(decoded.name, "特上にぎり 🍣")
        XCTAssertEqual(decoded.description, "最高級の寿司です。新鮮な魚を使用。")
        XCTAssertEqual(decoded.tags, ["特上", "高級", "新鮮"])
    }

    // MARK: - Sendable Tests

    func test_roll_shouldBeSendable() async throws {
        let roll = try Roll(
            id: RollID(),
            chefID: sampleChefID,
            restaurantID: sampleRestaurantID,
            type: .nigiri,
            name: "Sendable Roll",
            description: "Testing Sendable conformance",
            rating: XCTUnwrap(Rating(value: 4)),
            photoURL: nil,
            tags: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        // Test that Roll can be sent across actor boundaries
        let result = await withCheckedContinuation { continuation in
            Task {
                let processedRoll = await processRoll(roll)
                continuation.resume(returning: processedRoll)
            }
        }

        XCTAssertEqual(result.id, roll.id)
        XCTAssertEqual(result.name, "Sendable Roll")
    }

    func test_rollID_shouldBeSendable() async {
        let rollID = RollID()

        // Test that RollID can be sent across actor boundaries
        let result = await withCheckedContinuation { continuation in
            Task {
                let processedID = await processRollID(rollID)
                continuation.resume(returning: processedID)
            }
        }

        XCTAssertEqual(result, rollID)
    }

    func test_rating_shouldBeSendable() async throws {
        let rating = try XCTUnwrap(Rating(value: 5))

        // Test that Rating can be sent across actor boundaries
        let result = await withCheckedContinuation { continuation in
            Task {
                let processedRating = await processRating(rating)
                continuation.resume(returning: processedRating)
            }
        }

        XCTAssertEqual(result, rating)
    }

    func test_rollType_shouldBeSendable() async {
        let rollType = RollType.nigiri

        // Test that RollType can be sent across actor boundaries
        let result = await withCheckedContinuation { continuation in
            Task {
                let processedType = await processRollType(rollType)
                continuation.resume(returning: processedType)
            }
        }

        XCTAssertEqual(result, rollType)
    }

    // MARK: - Relationships Tests

    func test_roll_relationships_shouldMaintainIDs() throws {
        let chefID = ChefID()
        let restaurantID = RestaurantID()

        let roll = try Roll(
            id: RollID(),
            chefID: chefID,
            restaurantID: restaurantID,
            type: .nigiri,
            name: "Relationship Test",
            description: "Testing relationships",
            rating: XCTUnwrap(Rating(value: 4)),
            photoURL: nil,
            tags: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        XCTAssertEqual(roll.chefID, chefID)
        XCTAssertEqual(roll.restaurantID, restaurantID)
    }

    func test_roll_relationships_shouldBeDifferentObjects() throws {
        let chefID1 = ChefID()
        let chefID2 = ChefID()
        let restaurantID1 = RestaurantID()
        let restaurantID2 = RestaurantID()

        XCTAssertNotEqual(chefID1, chefID2)
        XCTAssertNotEqual(restaurantID1, restaurantID2)

        let roll1 = self.createRollWithRelationships(chefID: chefID1, restaurantID: restaurantID1)
        let roll2 = self.createRollWithRelationships(chefID: chefID2, restaurantID: restaurantID2)

        XCTAssertNotEqual(roll1.chefID, roll2.chefID)
        XCTAssertNotEqual(roll1.restaurantID, roll2.restaurantID)
    }

    private func createRollWithRelationships(chefID: ChefID, restaurantID: RestaurantID) -> Roll {
        Roll(
            id: RollID(),
            chefID: chefID,
            restaurantID: restaurantID,
            type: .nigiri,
            name: "Test Roll",
            description: "Test description",
            rating: Rating.default,
            photoURL: nil,
            tags: [],
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    // MARK: - Actor Helper Functions

    @MainActor
    private func processRoll(_ roll: Roll) async -> Roll {
        // Simulate processing on main actor
        roll
    }

    @MainActor
    private func processRollID(_ rollID: RollID) async -> RollID {
        // Simulate processing on main actor
        rollID
    }

    @MainActor
    private func processRating(_ rating: Rating) async -> Rating {
        // Simulate processing on main actor
        rating
    }

    @MainActor
    private func processRollType(_ rollType: RollType) async -> RollType {
        // Simulate processing on main actor
        rollType
    }
}
