//
// AppSecurityMigrationServiceTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class AppSecurityMigrationServiceTests: XCTestCase {
    var sut: AppSecurityMigrationService!
    var mockKeychain: MockKeychainService!
    var testUserDefaults: UserDefaults!

    override func setUp() async throws {
        try await super.setUp()

        // Create isolated UserDefaults for testing
        self.testUserDefaults = UserDefaults(suiteName: "com.rollcall.test.migration")!
        self.testUserDefaults.removePersistentDomain(forName: "com.rollcall.test.migration")

        self.mockKeychain = MockKeychainService()
        self.sut = AppSecurityMigrationService(keychain: self.mockKeychain, userDefaults: self.testUserDefaults)
    }

    override func tearDown() async throws {
        self.testUserDefaults.removePersistentDomain(forName: "com.rollcall.test.migration")
        self.testUserDefaults = nil
        self.mockKeychain = nil
        self.sut = nil
        try await super.tearDown()
    }

    func test_whenNoMigrationNeeded_shouldCompleteSuccessfully() async throws {
        // Given - no data in UserDefaults

        // When
        try await self.sut.performMigrationsIfNeeded()

        // Then
        XCTAssertTrue(self.testUserDefaults.bool(forKey: "security_migration_completed_v1"))
    }

    func test_whenMigrationNeeded_shouldMigrateData() async throws {
        // Given
        self.testUserDefaults.set("test@example.com", forKey: "user_email")
        self.testUserDefaults.set("test_token", forKey: "auth_token")

        // When
        try await self.sut.performMigrationsIfNeeded()

        // Then
        let emailData = try await mockKeychain.retrieve(for: "user_email")
        let tokenData = try await mockKeychain.retrieve(for: "auth_token")

        XCTAssertNotNil(emailData)
        XCTAssertNotNil(tokenData)
        XCTAssertEqual(String(data: emailData!, encoding: .utf8), "test@example.com")
        XCTAssertEqual(String(data: tokenData!, encoding: .utf8), "test_token")

        // UserDefaults should be cleared
        XCTAssertNil(self.testUserDefaults.string(forKey: "user_email"))
        XCTAssertNil(self.testUserDefaults.string(forKey: "auth_token"))

        // Migration should be marked as completed
        XCTAssertTrue(self.testUserDefaults.bool(forKey: "security_migration_completed_v1"))
    }

    func test_whenMigrationAlreadyCompleted_shouldSkipMigration() async throws {
        // Given
        self.testUserDefaults.set(true, forKey: "security_migration_completed_v1")
        self.testUserDefaults.set("should_not_migrate@example.com", forKey: "user_email")

        // When
        try await self.sut.performMigrationsIfNeeded()

        // Then - data should still be in UserDefaults (not migrated)
        XCTAssertEqual(self.testUserDefaults.string(forKey: "user_email"), "should_not_migrate@example.com")

        // Keychain should be empty
        let emailData = try await mockKeychain.retrieve(for: "user_email")
        XCTAssertNil(emailData)
    }

    func test_whenMigrationFails_shouldNotCrashApp() async throws {
        // Given
        self.testUserDefaults.set("test@example.com", forKey: "user_email")
        await self.mockKeychain.setShouldFail(true)

        // When - should not throw
        try await self.sut.performMigrationsIfNeeded()

        // Then - data should still be in UserDefaults
        XCTAssertEqual(self.testUserDefaults.string(forKey: "user_email"), "test@example.com")

        // Migration should NOT be marked as completed
        XCTAssertFalse(self.testUserDefaults.bool(forKey: "security_migration_completed_v1"))
    }

    func test_whenCalledMultipleTimes_shouldOnlyMigrateOnce() async throws {
        // Given
        self.testUserDefaults.set("test@example.com", forKey: "user_email")

        // When - call multiple times
        try await self.sut.performMigrationsIfNeeded()

        // Add new data after first migration
        self.testUserDefaults.set("new@example.com", forKey: "user_email")

        try await self.sut.performMigrationsIfNeeded()
        try await self.sut.performMigrationsIfNeeded()

        // Then - new data should NOT be migrated
        XCTAssertEqual(self.testUserDefaults.string(forKey: "user_email"), "new@example.com")

        // Only original data should be in keychain
        let emailData = try await mockKeychain.retrieve(for: "user_email")
        XCTAssertEqual(String(data: emailData!, encoding: .utf8), "test@example.com")
    }
}
