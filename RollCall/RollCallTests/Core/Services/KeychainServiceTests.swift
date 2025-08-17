//
// KeychainServiceTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class KeychainServiceTests: XCTestCase {
    var sut: KeychainService!
    let testService = "com.rollcall.test"
    let testKey = "test_key"
    let testData = Data("test_password_123".utf8)

    override func setUp() async throws {
        try await super.setUp()
        self.sut = KeychainService(service: self.testService)
        // Clean up any existing test data
        _ = try? await self.sut.deleteAll()
    }

    override func tearDown() async throws {
        // Clean up after each test
        _ = try? await self.sut.deleteAll()
        self.sut = nil
        try await super.tearDown()
    }

    // MARK: - Save Tests

    func test_whenSavingData_shouldSucceed() async throws {
        // When
        let result = try await sut.save(self.testData, for: self.testKey, accessibility: .whenUnlockedThisDeviceOnly)

        // Then
        XCTAssertTrue(result, "Save operation should succeed")
    }

    func test_whenSavingDuplicateKey_shouldUpdateExisting() async throws {
        // Given
        let firstData = Data("first".utf8)
        let secondData = Data("second".utf8)

        // When
        _ = try await self.sut.save(firstData, for: self.testKey, accessibility: .whenUnlockedThisDeviceOnly)
        let result = try await sut.save(secondData, for: self.testKey, accessibility: .whenUnlockedThisDeviceOnly)

        // Then
        XCTAssertTrue(result, "Should succeed by updating existing item")
        let retrieved = try await sut.retrieve(for: self.testKey)
        XCTAssertEqual(retrieved, secondData, "Should retrieve the updated data")
    }

    func test_whenSavingEmptyData_shouldSucceed() async throws {
        // Given
        let emptyData = Data()

        // When
        let result = try await sut.save(emptyData, for: self.testKey, accessibility: .whenUnlockedThisDeviceOnly)

        // Then
        XCTAssertTrue(result, "Should handle empty data")
    }

    // MARK: - Retrieve Tests

    func test_whenRetrievingExistingData_shouldReturnCorrectData() async throws {
        // Given
        _ = try await self.sut.save(self.testData, for: self.testKey, accessibility: .whenUnlockedThisDeviceOnly)

        // When
        let retrieved = try await sut.retrieve(for: self.testKey)

        // Then
        XCTAssertEqual(retrieved, self.testData, "Retrieved data should match saved data")
    }

    func test_whenRetrievingNonexistentKey_shouldReturnNil() async throws {
        // When
        let retrieved = try await sut.retrieve(for: "nonexistent_key")

        // Then
        XCTAssertNil(retrieved, "Should return nil for non-existent key")
    }

    // MARK: - Update Tests

    func test_whenUpdatingExistingData_shouldSucceed() async throws {
        // Given
        _ = try await self.sut.save(self.testData, for: self.testKey, accessibility: .whenUnlockedThisDeviceOnly)
        let newData = Data("updated_password".utf8)

        // When
        let result = try await sut.update(newData, for: self.testKey)

        // Then
        XCTAssertTrue(result, "Update should succeed")
        let retrieved = try await sut.retrieve(for: self.testKey)
        XCTAssertEqual(retrieved, newData, "Should retrieve updated data")
    }

    func test_whenUpdatingNonexistentKey_shouldFail() async throws {
        // Given
        let newData = Data("new_data".utf8)

        // When/Then
        do {
            _ = try await self.sut.update(newData, for: "nonexistent_key")
            XCTFail("Update should fail for non-existent key")
        } catch {
            XCTAssertTrue(error is KeychainError, "Should throw KeychainError")
        }
    }

    // MARK: - Delete Tests

    func test_whenDeletingExistingKey_shouldSucceed() async throws {
        // Given
        _ = try await self.sut.save(self.testData, for: self.testKey, accessibility: .whenUnlockedThisDeviceOnly)

        // When
        let result = try await sut.delete(for: self.testKey)

        // Then
        XCTAssertTrue(result, "Delete should succeed")
        let retrieved = try await sut.retrieve(for: self.testKey)
        XCTAssertNil(retrieved, "Data should be deleted")
    }

    func test_whenDeletingNonexistentKey_shouldSucceed() async throws {
        // When
        let result = try await sut.delete(for: "nonexistent_key")

        // Then
        XCTAssertTrue(result, "Delete should succeed even for non-existent key")
    }

    // MARK: - Delete All Tests

    func test_whenDeletingAll_shouldRemoveAllItems() async throws {
        // Given
        let keys = ["key1", "key2", "key3"]
        for key in keys {
            _ = try await self.sut.save(self.testData, for: key, accessibility: .whenUnlockedThisDeviceOnly)
        }

        // When
        let result = try await sut.deleteAll()

        // Then
        XCTAssertTrue(result, "Delete all should succeed")
        for key in keys {
            let retrieved = try await sut.retrieve(for: key)
            XCTAssertNil(retrieved, "All data should be deleted")
        }
    }

    // MARK: - Accessibility Tests

    func test_whenSavingWithDifferentAccessibility_shouldRespectSettings() async throws {
        // Given
        let accessibilityOptions: [KeychainAccessibility] = [
            .whenUnlocked,
            .whenUnlockedThisDeviceOnly,
            .afterFirstUnlock,
            .afterFirstUnlockThisDeviceOnly
        ]

        // When/Then
        for (index, accessibility) in accessibilityOptions.enumerated() {
            let key = "key_\(index)"
            let result = try await sut.save(self.testData, for: key, accessibility: accessibility)
            XCTAssertTrue(result, "Save should succeed with \(accessibility)")
        }
    }

    // MARK: - Concurrent Access Tests

    func test_whenAccessingConcurrently_shouldHandleSafely() async throws {
        // Given
        let iterations = 100

        // When
        await withTaskGroup(of: Void.self) { group in
            // Concurrent saves
            for index in 0..<iterations {
                group.addTask { [weak self] in
                    guard let self else { return }
                    let data = Data("data_\(index)".utf8)
                    _ = try? await self.sut.save(
                        data,
                        for: "concurrent_\(index)",
                        accessibility: .whenUnlockedThisDeviceOnly
                    )
                }
            }

            // Concurrent reads
            for index in 0..<iterations {
                group.addTask { [weak self] in
                    guard let self else { return }
                    _ = try? await self.sut.retrieve(for: "concurrent_\(index)")
                }
            }
        }

        // Then - should not crash or deadlock
        XCTAssertTrue(true, "Concurrent access should be handled safely")
    }
}

// MARK: - Migration Tests

@available(iOS 15.0, *)
final class KeychainMigrationTests: XCTestCase {
    var migrator: KeychainMigrator!
    var keychain: KeychainService!
    let testService = "com.rollcall.test.migration"

    override func setUp() async throws {
        try await super.setUp()
        self.keychain = KeychainService(service: self.testService)
        self.migrator = KeychainMigrator(keychain: self.keychain)

        // Clean up
        UserDefaults.standard.removeObject(forKey: "user_email")
        UserDefaults.standard.removeObject(forKey: "auth_token")
        _ = try? await self.keychain.deleteAll()
    }

    override func tearDown() async throws {
        // Clean up
        UserDefaults.standard.removeObject(forKey: "user_email")
        UserDefaults.standard.removeObject(forKey: "auth_token")
        _ = try? await self.keychain.deleteAll()

        self.migrator = nil
        self.keychain = nil
        try await super.tearDown()
    }

    func test_whenMigratingFromUserDefaults_shouldMoveDataToKeychain() async throws {
        // Given
        let email = "test@example.com"
        let token = "test_auth_token_123"
        UserDefaults.standard.set(email, forKey: "user_email")
        UserDefaults.standard.set(token, forKey: "auth_token")

        // When
        try await self.migrator.migrateFromUserDefaults()

        // Then
        let emailData = try await keychain.retrieve(for: "user_email")
        let tokenData = try await keychain.retrieve(for: "auth_token")

        XCTAssertEqual(try String(data: XCTUnwrap(emailData), encoding: .utf8), email)
        XCTAssertEqual(try String(data: XCTUnwrap(tokenData), encoding: .utf8), token)

        // UserDefaults should be cleared
        XCTAssertNil(UserDefaults.standard.string(forKey: "user_email"))
        XCTAssertNil(UserDefaults.standard.string(forKey: "auth_token"))
    }

    func test_whenNoDataInUserDefaults_shouldCompleteWithoutError() async throws {
        // When/Then - should not throw
        try await self.migrator.migrateFromUserDefaults()
    }

    func test_whenMigrationFails_shouldNotDeleteUserDefaultsData() async throws {
        // Given
        let email = "test@example.com"
        UserDefaults.standard.set(email, forKey: "user_email")

        // Create a migrator with a failing keychain
        let failingKeychain = FailingKeychainService()
        let failingMigrator = KeychainMigrator(keychain: failingKeychain)

        // When/Then
        do {
            try await failingMigrator.migrateFromUserDefaults()
            XCTFail("Migration should fail")
        } catch {
            // UserDefaults data should still exist
            XCTAssertEqual(UserDefaults.standard.string(forKey: "user_email"), email)
        }
    }
}

// MARK: - Mock for Testing

@available(iOS 15.0, *)
private actor FailingKeychainService: KeychainServicing {
    func save(_: Data, for _: String, accessibility _: KeychainAccessibility) async throws -> Bool {
        throw KeychainError.operationFailed(-1)
    }

    func retrieve(for _: String) async throws -> Data? {
        throw KeychainError.operationFailed(-1)
    }

    func update(_: Data, for _: String) async throws -> Bool {
        throw KeychainError.operationFailed(-1)
    }

    func delete(for _: String) async throws -> Bool {
        throw KeychainError.operationFailed(-1)
    }

    func deleteAll() async throws -> Bool {
        throw KeychainError.operationFailed(-1)
    }
}
