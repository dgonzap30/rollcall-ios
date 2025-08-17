//
// ChefTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class ChefTests: XCTestCase {
    // MARK: - Initialization Tests

    func test_init_withAllProperties_createsChef() {
        let id = ChefID()
        let avatarURL = URL(string: "https://example.com/avatar.jpg")!
        let joinedAt = Date().addingTimeInterval(-86400)
        let lastActiveAt = Date()

        let chef = Chef(
            id: id,
            username: "sushimaster",
            displayName: "Sushi Master",
            email: "master@sushi.com",
            bio: "Making sushi since 1990",
            avatarURL: avatarURL,
            favoriteRollType: .nigiri,
            rollCount: 100,
            joinedAt: joinedAt,
            lastActiveAt: lastActiveAt
        )

        XCTAssertEqual(chef.id, id)
        XCTAssertEqual(chef.username, "sushimaster")
        XCTAssertEqual(chef.displayName, "Sushi Master")
        XCTAssertEqual(chef.email, "master@sushi.com")
        XCTAssertEqual(chef.bio, "Making sushi since 1990")
        XCTAssertEqual(chef.avatarURL, avatarURL)
        XCTAssertEqual(chef.favoriteRollType, .nigiri)
        XCTAssertEqual(chef.rollCount, 100)
        XCTAssertEqual(chef.joinedAt, joinedAt)
        XCTAssertEqual(chef.lastActiveAt, lastActiveAt)
    }

    func test_init_withOptionalNilValues_createsChef() {
        let chef = Chef(
            id: ChefID(),
            username: "minimal",
            displayName: "Minimal Chef",
            email: "minimal@example.com",
            bio: nil,
            avatarURL: nil,
            favoriteRollType: nil,
            rollCount: 0,
            joinedAt: Date(),
            lastActiveAt: Date()
        )

        XCTAssertNil(chef.bio)
        XCTAssertNil(chef.avatarURL)
        XCTAssertNil(chef.favoriteRollType)
        XCTAssertEqual(chef.rollCount, 0)
    }

    // MARK: - ChefID Tests

    func test_chefID_uniqueness() {
        let id1 = ChefID()
        let id2 = ChefID()

        XCTAssertNotEqual(id1.value, id2.value)
        XCTAssertNotEqual(id1, id2)
    }

    func test_chefID_initWithValue() {
        let uuid = UUID()
        let id = ChefID(value: uuid)

        XCTAssertEqual(id.value, uuid)
    }

    func test_chefID_hashable() {
        let id1 = ChefID()
        let id2 = ChefID(value: id1.value)
        let id3 = ChefID()

        var set = Set<ChefID>()
        set.insert(id1)
        set.insert(id2)
        set.insert(id3)

        XCTAssertEqual(set.count, 2)
        XCTAssertTrue(set.contains(id1))
        XCTAssertTrue(set.contains(id2))
        XCTAssertTrue(set.contains(id3))
    }

    // MARK: - Equatable Tests

    func test_equatable_sameValues_areEqual() {
        let id = ChefID()
        let date = Date()

        let chef1 = Chef(
            id: id,
            username: "test",
            displayName: "Test",
            email: "test@example.com",
            bio: "Bio",
            avatarURL: nil,
            favoriteRollType: .maki,
            rollCount: 5,
            joinedAt: date,
            lastActiveAt: date
        )

        let chef2 = Chef(
            id: id,
            username: "test",
            displayName: "Test",
            email: "test@example.com",
            bio: "Bio",
            avatarURL: nil,
            favoriteRollType: .maki,
            rollCount: 5,
            joinedAt: date,
            lastActiveAt: date
        )

        XCTAssertEqual(chef1, chef2)
    }

    func test_equatable_differentIds_areNotEqual() {
        let chef1 = Chef(
            id: ChefID(),
            username: "test",
            displayName: "Test",
            email: "test@example.com",
            bio: nil,
            avatarURL: nil,
            favoriteRollType: nil,
            rollCount: 0,
            joinedAt: Date(),
            lastActiveAt: Date()
        )

        let chef2 = Chef(
            id: ChefID(),
            username: "test",
            displayName: "Test",
            email: "test@example.com",
            bio: nil,
            avatarURL: nil,
            favoriteRollType: nil,
            rollCount: 0,
            joinedAt: Date(),
            lastActiveAt: Date()
        )

        XCTAssertNotEqual(chef1, chef2)
    }

    // MARK: - Codable Tests

    func test_codable_encodeDecode() throws {
        let original = Chef(
            id: ChefID(),
            username: "codabletest",
            displayName: "Codable Test",
            email: "codable@test.com",
            bio: "Testing codable",
            avatarURL: URL(string: "https://example.com/avatar.jpg"),
            favoriteRollType: .sashimi,
            rollCount: 42,
            joinedAt: Date(),
            lastActiveAt: Date()
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Chef.self, from: data)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.username, original.username)
        XCTAssertEqual(decoded.displayName, original.displayName)
        XCTAssertEqual(decoded.email, original.email)
        XCTAssertEqual(decoded.bio, original.bio)
        XCTAssertEqual(decoded.avatarURL, original.avatarURL)
        XCTAssertEqual(decoded.favoriteRollType, original.favoriteRollType)
        XCTAssertEqual(decoded.rollCount, original.rollCount)
    }

    func test_codable_withNilValues() throws {
        let original = Chef(
            id: ChefID(),
            username: "niltest",
            displayName: "Nil Test",
            email: "nil@test.com",
            bio: nil,
            avatarURL: nil,
            favoriteRollType: nil,
            rollCount: 0,
            joinedAt: Date(),
            lastActiveAt: Date()
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Chef.self, from: data)

        XCTAssertNil(decoded.bio)
        XCTAssertNil(decoded.avatarURL)
        XCTAssertNil(decoded.favoriteRollType)
    }

    // MARK: - Sendable Tests

    func test_sendable_canBeSentAcrossActors() async {
        let chef = Chef(
            id: ChefID(),
            username: "sendable",
            displayName: "Sendable Chef",
            email: "sendable@test.com",
            bio: nil,
            avatarURL: nil,
            favoriteRollType: nil,
            rollCount: 0,
            joinedAt: Date(),
            lastActiveAt: Date()
        )

        actor TestActor {
            func process(chef: Chef) -> String {
                chef.username
            }
        }

        let actor = TestActor()
        let username = await actor.process(chef: chef)

        XCTAssertEqual(username, "sendable")
    }
}
