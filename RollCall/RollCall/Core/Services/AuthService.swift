//
// AuthService.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

// MARK: - Auth Credentials

/// Secure storage structure for authentication data
@available(iOS 15.0, *)
struct AuthCredentials: Codable {
    let email: String
    let token: String
    let chefId: String
    let refreshToken: String?
    let expiresAt: Date?
}

// MARK: - Auth Service Implementation

@available(iOS 15.0, macOS 12.0, *)
final class AuthService: AuthServicing {
    private var currentChef: Chef?
    let keychain: KeychainServicing
    private let credentialsKey = "auth_credentials"

    init(keychain: KeychainServicing? = nil) {
        self.keychain = keychain ?? KeychainService()
    }

    func login(email: String, password: String) async throws -> Chef {
        // Simulate API call delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        // Basic validation
        guard !email.isEmpty, !password.isEmpty else {
            throw AuthError.invalidCredentials
        }

        // Mock authentication - in real app, this would call backend
        let chef = Chef(
            id: ChefID(value: UUID()),
            username: extractUsernameFromEmail(email),
            displayName: extractUsernameFromEmail(email),
            email: email,
            bio: nil,
            avatarURL: nil,
            favoriteRollType: nil,
            rollCount: 0,
            joinedAt: Date(),
            lastActiveAt: Date()
        )

        self.currentChef = chef

        // Store credentials securely in keychain
        let credentials = AuthCredentials(
            email: email,
            token: "mock_token_\(chef.id.value)",
            chefId: chef.id.value.uuidString,
            refreshToken: "mock_refresh_\(chef.id.value)",
            expiresAt: Date().addingTimeInterval(3600) // 1 hour
        )

        let credentialsData = try JSONEncoder().encode(credentials)
        _ = try await self.keychain.save(
            credentialsData,
            for: self.credentialsKey,
            accessibility: .whenUnlockedThisDeviceOnly
        )

        return chef
    }

    func logout() async throws {
        self.currentChef = nil
        _ = try await self.keychain.delete(for: self.credentialsKey)
    }

    func signup(email: String, password: String, username: String) async throws -> Chef {
        // Simulate API call delay
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Basic validation
        guard !email.isEmpty, !password.isEmpty, !username.isEmpty else {
            throw AuthError.invalidCredentials
        }

        guard password.count >= 8 else {
            throw AuthError.weakPassword
        }

        // Mock signup - in real app, this would call backend
        let chef = Chef(
            id: ChefID(value: UUID()),
            username: username,
            displayName: username,
            email: email,
            bio: nil,
            avatarURL: nil,
            favoriteRollType: nil,
            rollCount: 0,
            joinedAt: Date(),
            lastActiveAt: Date()
        )

        self.currentChef = chef

        // Store credentials securely in keychain
        let credentials = AuthCredentials(
            email: email,
            token: "mock_token_\(chef.id.value)",
            chefId: chef.id.value.uuidString,
            refreshToken: "mock_refresh_\(chef.id.value)",
            expiresAt: Date().addingTimeInterval(3600) // 1 hour
        )

        let credentialsData = try JSONEncoder().encode(credentials)
        _ = try await self.keychain.save(
            credentialsData,
            for: self.credentialsKey,
            accessibility: .whenUnlockedThisDeviceOnly
        )

        return chef
    }

    func getCurrentChef() async throws -> Chef? {
        // If we have current chef in memory, return it
        if let chef = currentChef {
            return chef
        }

        // Otherwise, try to restore from keychain
        if let credentialsData = try await keychain.retrieve(for: credentialsKey) {
            let credentials = try JSONDecoder().decode(AuthCredentials.self, from: credentialsData)

            // Check if token is expired
            if let expiresAt = credentials.expiresAt, expiresAt < Date() {
                // Token expired, clear and return nil
                _ = try? await self.keychain.delete(for: self.credentialsKey)
                return nil
            }

            // In real app, would validate token with backend
            // For now, recreate chef from stored data
            let chef = Chef(
                id: ChefID(value: UUID(uuidString: credentials.chefId) ?? UUID()),
                username: self.extractUsernameFromEmail(credentials.email),
                displayName: self.extractUsernameFromEmail(credentials.email),
                email: credentials.email,
                bio: nil,
                avatarURL: nil,
                favoriteRollType: nil,
                rollCount: 0,
                joinedAt: Date(),
                lastActiveAt: Date()
            )
            self.currentChef = chef
            return chef
        }

        return nil
    }

    func updateProfile(_ chef: Chef) async throws -> Chef {
        // Simulate API call
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        self.currentChef = chef
        return chef
    }

    func deleteAccount() async throws {
        // Simulate API call
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second

        self.currentChef = nil
        _ = try await self.keychain.delete(for: self.credentialsKey)
    }

    func requestPasswordReset(email: String) async throws {
        // Simulate API call
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8 seconds

        guard !email.isEmpty else {
            throw AuthError.invalidCredentials
        }
    }

    // MARK: - Private Methods

    private func extractUsernameFromEmail(_ email: String) -> String {
        String(email.split(separator: "@").first ?? "user")
    }
}

// MARK: - Mock Auth Service for Testing

@available(iOS 15.0, macOS 12.0, *)
final class MockAuthService: AuthServicing {
    var shouldSucceed = true
    var currentMockChef: Chef?

    init() {}

    func login(email: String, password _: String) async throws -> Chef {
        guard self.shouldSucceed else {
            throw AuthError.invalidCredentials
        }

        let chef = Chef(
            id: ChefID(value: UUID()),
            username: "test_user",
            displayName: "Test User",
            email: email,
            bio: nil,
            avatarURL: nil,
            favoriteRollType: nil,
            rollCount: 0,
            joinedAt: Date(),
            lastActiveAt: Date()
        )

        self.currentMockChef = chef
        return chef
    }

    func logout() async throws {
        self.currentMockChef = nil
    }

    func signup(email: String, password _: String, username: String) async throws -> Chef {
        guard self.shouldSucceed else {
            throw AuthError.emailAlreadyInUse
        }

        let chef = Chef(
            id: ChefID(value: UUID()),
            username: username,
            displayName: username,
            email: email,
            bio: nil,
            avatarURL: nil,
            favoriteRollType: nil,
            rollCount: 0,
            joinedAt: Date(),
            lastActiveAt: Date()
        )

        self.currentMockChef = chef
        return chef
    }

    func getCurrentChef() async throws -> Chef? {
        self.currentMockChef
    }

    func updateProfile(_ chef: Chef) async throws -> Chef {
        self.currentMockChef = chef
        return chef
    }

    func deleteAccount() async throws {
        self.currentMockChef = nil
    }

    func requestPasswordReset(email _: String) async throws {
        // Mock implementation - always succeeds if shouldSucceed is true
    }
}
