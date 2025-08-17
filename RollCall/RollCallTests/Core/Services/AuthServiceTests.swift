//
// AuthServiceTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class AuthServiceTests: XCTestCase {
    var sut: AuthService!
    var mockKeychain: MockKeychainService!
    let testEmail = "test@example.com"
    let testPassword = "securePassword123"
    let testUsername = "testuser"

    override func setUp() async throws {
        try await super.setUp()
        self.mockKeychain = MockKeychainService()
        self.sut = AuthService(keychain: self.mockKeychain)
    }

    override func tearDown() async throws {
        self.sut = nil
        self.mockKeychain = nil
        try await super.tearDown()
    }

    // MARK: - Login Tests

    func test_whenLoginWithValidCredentials_shouldReturnChef() async throws {
        // When
        let chef = try await sut.login(email: self.testEmail, password: self.testPassword)

        // Then
        XCTAssertEqual(chef.email, self.testEmail)
        XCTAssertEqual(chef.username, "test")
        XCTAssertNotNil(chef.id)

        // Verify token stored in keychain
        let storedData = try await mockKeychain.retrieve(for: "auth_credentials")
        XCTAssertNotNil(storedData)
    }

    func test_whenLoginWithEmptyEmail_shouldThrowError() async throws {
        // When/Then
        do {
            _ = try await self.sut.login(email: "", password: self.testPassword)
            XCTFail("Should throw invalidCredentials error")
        } catch {
            XCTAssertEqual(error as? AuthError, .invalidCredentials)
        }
    }

    func test_whenLoginWithEmptyPassword_shouldThrowError() async throws {
        // When/Then
        do {
            _ = try await self.sut.login(email: self.testEmail, password: "")
            XCTFail("Should throw invalidCredentials error")
        } catch {
            XCTAssertEqual(error as? AuthError, .invalidCredentials)
        }
    }

    // MARK: - Logout Tests

    func test_whenLogout_shouldClearStoredCredentials() async throws {
        // Given
        _ = try await self.sut.login(email: self.testEmail, password: self.testPassword)

        // When
        try await self.sut.logout()

        // Then
        let storedData = try await mockKeychain.retrieve(for: "auth_credentials")
        XCTAssertNil(storedData)

        let currentChef = try await sut.getCurrentChef()
        XCTAssertNil(currentChef)
    }

    // MARK: - Signup Tests

    func test_whenSignupWithValidData_shouldReturnChef() async throws {
        // When
        let chef = try await sut.signup(email: self.testEmail, password: self.testPassword, username: self.testUsername)

        // Then
        XCTAssertEqual(chef.email, self.testEmail)
        XCTAssertEqual(chef.username, self.testUsername)
        XCTAssertEqual(chef.displayName, self.testUsername)

        // Verify stored in keychain
        let storedData = try await mockKeychain.retrieve(for: "auth_credentials")
        XCTAssertNotNil(storedData)
    }

    func test_whenSignupWithWeakPassword_shouldThrowError() async throws {
        // When/Then
        do {
            _ = try await self.sut.signup(email: self.testEmail, password: "weak", username: self.testUsername)
            XCTFail("Should throw weakPassword error")
        } catch {
            XCTAssertEqual(error as? AuthError, .weakPassword)
        }
    }

    func test_whenSignupWithEmptyUsername_shouldThrowError() async throws {
        // When/Then
        do {
            _ = try await self.sut.signup(email: self.testEmail, password: self.testPassword, username: "")
            XCTFail("Should throw invalidCredentials error")
        } catch {
            XCTAssertEqual(error as? AuthError, .invalidCredentials)
        }
    }

    // MARK: - Get Current Chef Tests

    func test_whenGettingCurrentChefAfterLogin_shouldReturnChef() async throws {
        // Given
        let loginChef = try await sut.login(email: self.testEmail, password: self.testPassword)

        // When
        let currentChef = try await sut.getCurrentChef()

        // Then
        XCTAssertNotNil(currentChef)
        XCTAssertEqual(currentChef?.email, loginChef.email)
    }

    func test_whenGettingCurrentChefWithoutLogin_shouldReturnNil() async throws {
        // When
        let currentChef = try await sut.getCurrentChef()

        // Then
        XCTAssertNil(currentChef)
    }

    func test_whenGettingCurrentChefFromKeychain_shouldRestoreSession() async throws {
        // Given - simulate stored credentials
        let credentials = AuthCredentials(
            email: testEmail,
            token: "mock_token_123",
            chefId: UUID().uuidString,
            refreshToken: "mock_refresh_123",
            expiresAt: Date().addingTimeInterval(3600)
        )
        let data = try JSONEncoder().encode(credentials)
        _ = try await self.mockKeychain.save(data, for: "auth_credentials", accessibility: .whenUnlockedThisDeviceOnly)

        // Create new AuthService to simulate app restart
        let newAuthService = AuthService(keychain: mockKeychain)

        // When
        let currentChef = try await newAuthService.getCurrentChef()

        // Then
        XCTAssertNotNil(currentChef)
        XCTAssertEqual(currentChef?.email, self.testEmail)
    }

    // MARK: - Update Profile Tests

    func test_whenUpdatingProfile_shouldReturnUpdatedChef() async throws {
        // Given
        let chef = try await sut.login(email: self.testEmail, password: self.testPassword)
        let updatedChef = Chef(
            id: chef.id,
            username: chef.username,
            displayName: "Updated Name",
            email: chef.email,
            bio: "New bio",
            avatarURL: chef.avatarURL,
            favoriteRollType: chef.favoriteRollType,
            rollCount: chef.rollCount,
            joinedAt: chef.joinedAt,
            lastActiveAt: Date()
        )

        // When
        let result = try await sut.updateProfile(updatedChef)

        // Then
        XCTAssertEqual(result.displayName, "Updated Name")
        XCTAssertEqual(result.bio, "New bio")

        let currentChef = try await sut.getCurrentChef()
        XCTAssertEqual(currentChef?.displayName, "Updated Name")
    }

    // MARK: - Delete Account Tests

    func test_whenDeletingAccount_shouldClearAllData() async throws {
        // Given
        _ = try await self.sut.login(email: self.testEmail, password: self.testPassword)

        // When
        try await self.sut.deleteAccount()

        // Then
        let currentChef = try await sut.getCurrentChef()
        XCTAssertNil(currentChef)

        let storedData = try await mockKeychain.retrieve(for: "auth_credentials")
        XCTAssertNil(storedData)
    }

    // MARK: - Password Reset Tests

    func test_whenRequestingPasswordReset_shouldSucceed() async throws {
        // When/Then - should not throw
        try await self.sut.requestPasswordReset(email: self.testEmail)
    }

    func test_whenRequestingPasswordResetWithEmptyEmail_shouldThrowError() async throws {
        // When/Then
        do {
            try await self.sut.requestPasswordReset(email: "")
            XCTFail("Should throw invalidCredentials error")
        } catch {
            XCTAssertEqual(error as? AuthError, .invalidCredentials)
        }
    }

    // MARK: - Keychain Failure Tests

    func test_whenKeychainFailsDuringLogin_shouldThrowError() async throws {
        // Given
        await self.mockKeychain.setShouldFail(true)

        // When/Then
        do {
            _ = try await self.sut.login(email: self.testEmail, password: self.testPassword)
            XCTFail("Should throw error when keychain fails")
        } catch {
            XCTAssertTrue(error is KeychainError)
        }
    }

    func test_whenKeychainFailsDuringLogout_shouldThrowError() async throws {
        // Given
        _ = try await self.sut.login(email: self.testEmail, password: self.testPassword)
        await self.mockKeychain.setShouldFail(true)

        // When/Then
        do {
            try await self.sut.logout()
            XCTFail("Should throw error when keychain fails")
        } catch {
            XCTAssertTrue(error is KeychainError)
        }
    }
}

// MARK: - Integration Tests

@available(iOS 15.0, *)
final class AuthServiceIntegrationTests: XCTestCase {
    var sut: AuthService!
    var migrator: KeychainMigrator!
    let testEmail = "integration@example.com"
    let testToken = "integration_token_123"

    override func setUp() async throws {
        try await super.setUp()

        // Use real keychain with test service
        let keychain = KeychainService(service: "com.rollcall.test.auth")
        self.sut = AuthService(keychain: keychain)
        self.migrator = KeychainMigrator(keychain: keychain)

        // Clean up
        _ = try? await keychain.deleteAll()
        UserDefaults.standard.removeObject(forKey: "user_email")
        UserDefaults.standard.removeObject(forKey: "auth_token")
    }

    override func tearDown() async throws {
        // Clean up
        if let keychain = sut.keychain as? KeychainService {
            _ = try? await keychain.deleteAll()
        }
        UserDefaults.standard.removeObject(forKey: "user_email")
        UserDefaults.standard.removeObject(forKey: "auth_token")

        self.sut = nil
        self.migrator = nil
        try await super.tearDown()
    }

    func test_whenMigratingExistingUserDefaultsData_shouldRestoreSession() async throws {
        // Given - simulate old app version with data in UserDefaults
        UserDefaults.standard.set(self.testEmail, forKey: "user_email")
        UserDefaults.standard.set(self.testToken, forKey: "auth_token")

        // When - run migration
        try await self.migrator.migrateFromUserDefaults()

        // Then - AuthService should be able to restore session
        let chef = try await sut.getCurrentChef()
        XCTAssertNotNil(chef)
        XCTAssertEqual(chef?.email, self.testEmail)

        // UserDefaults should be cleared
        XCTAssertNil(UserDefaults.standard.string(forKey: "user_email"))
        XCTAssertNil(UserDefaults.standard.string(forKey: "auth_token"))
    }
}
