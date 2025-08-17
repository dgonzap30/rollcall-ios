//
// CoreDataChefRepositoryTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import CoreData
@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class CoreDataChefRepositoryTests: XCTestCase {
    var coreDataStack: CoreDataStack!
    var sut: CoreDataChefRepository!

    override func setUp() {
        super.setUp()
        self.coreDataStack = CoreDataStack.makeTestStack()
        self.sut = CoreDataChefRepository(coreDataStack: self.coreDataStack)
    }

    override func tearDown() {
        Task {
            try? await self.coreDataStack.deleteAllData()
        }
        UserDefaults.standard.removeObject(forKey: "com.rollcall.currentChefId")
        self.sut = nil
        self.coreDataStack = nil
        super.tearDown()
    }

    // MARK: - Create Chef Tests

    func test_createChef_savesChefToDatabase() async throws {
        let chef = self.makeTestChef()

        let createdChef = try await sut.createChef(chef)

        XCTAssertEqual(createdChef.id, chef.id)
        XCTAssertEqual(createdChef.username, chef.username)
        XCTAssertEqual(createdChef.email, chef.email)
    }

    func test_createChef_setsAsCurrentIfNoCurrentChef() async throws {
        let chef = self.makeTestChef()

        _ = try await self.sut.createChef(chef)
        let currentChef = try await sut.fetchCurrentChef()

        XCTAssertNotNil(currentChef)
        XCTAssertEqual(currentChef?.id, chef.id)
    }

    func test_createChef_doesNotOverrideExistingCurrentChef() async throws {
        let firstChef = self.makeTestChef()
        let secondChef = self.makeTestChef(username: "chef2", email: "chef2@example.com")

        _ = try await self.sut.createChef(firstChef)
        _ = try await self.sut.createChef(secondChef)

        let currentChef = try await sut.fetchCurrentChef()
        XCTAssertEqual(currentChef?.id, firstChef.id)
    }

    // MARK: - Fetch Chef Tests

    func test_fetchChef_returnsChefWhenExists() async throws {
        let chef = self.makeTestChef()
        _ = try await self.sut.createChef(chef)

        let fetchedChef = try await sut.fetchChef(by: chef.id)

        XCTAssertNotNil(fetchedChef)
        XCTAssertEqual(fetchedChef?.id, chef.id)
    }

    func test_fetchChef_returnsNilWhenNotExists() async throws {
        let nonExistentId = ChefID()

        let fetchedChef = try await sut.fetchChef(by: nonExistentId)

        XCTAssertNil(fetchedChef)
    }

    // MARK: - Update Chef Tests

    func test_updateChef_updatesExistingChef() async throws {
        let chef = self.makeTestChef()
        _ = try await self.sut.createChef(chef)

        // Create a new chef with updated properties
        let updatedChef = Chef(
            id: chef.id,
            username: chef.username,
            displayName: "Updated Name",
            email: chef.email,
            bio: "Updated bio",
            avatarURL: chef.avatarURL,
            favoriteRollType: chef.favoriteRollType,
            rollCount: chef.rollCount,
            joinedAt: chef.joinedAt,
            lastActiveAt: Date()
        )

        let result = try await sut.updateChef(updatedChef)

        XCTAssertEqual(result.displayName, "Updated Name")
        XCTAssertEqual(result.bio, "Updated bio")
    }

    func test_updateChef_throwsWhenChefNotFound() async throws {
        let chef = self.makeTestChef()

        do {
            _ = try await self.sut.updateChef(chef)
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertTrue(error is AppError)
            if case AppError.notFound = error {
                // Success
            } else {
                XCTFail("Expected notFound error")
            }
        }
    }

    // MARK: - Current Chef Tests

    func test_fetchCurrentChef_returnsNilWhenNoCurrentChef() async throws {
        let currentChef = try await sut.fetchCurrentChef()
        XCTAssertNil(currentChef)
    }

    func test_setCurrentChef_updatesCurrentChef() async throws {
        let chef = self.makeTestChef()
        _ = try await self.sut.createChef(chef)

        self.sut.setCurrentChef(chef)
        let currentChef = try await sut.fetchCurrentChef()

        XCTAssertEqual(currentChef?.id, chef.id)
    }

    func test_clearCurrentChef_removesCurrentChef() async throws {
        let chef = self.makeTestChef()
        _ = try await self.sut.createChef(chef)

        self.sut.clearCurrentChef()
        let currentChef = try await sut.fetchCurrentChef()

        XCTAssertNil(currentChef)
    }

    // MARK: - Helpers

    private func makeTestChef(
        username: String = "testchef",
        email: String = "test@example.com"
    ) -> Chef {
        Chef(
            id: ChefID(value: UUID()),
            username: username,
            displayName: "Test Chef",
            email: email,
            bio: "Test bio",
            avatarURL: nil,
            favoriteRollType: .maki,
            rollCount: 0,
            joinedAt: Date(),
            lastActiveAt: Date()
        )
    }
}
