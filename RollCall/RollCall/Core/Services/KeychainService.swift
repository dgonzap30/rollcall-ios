//
// KeychainService.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Foundation
import Security

// MARK: - Keychain Service Implementation

/// Secure storage service using iOS Keychain
@available(iOS 15.0, *)
actor KeychainService: KeychainServicing {
    private let service: String
    private let accessGroup: String?

    /// Initializes the keychain service
    /// - Parameters:
    ///   - service: The service identifier for keychain items
    ///   - accessGroup: Optional access group for sharing between apps
    init(service: String = "com.rollcall.app", accessGroup: String? = nil) {
        self.service = service
        self.accessGroup = accessGroup
    }

    // MARK: - KeychainServicing Protocol

    func save(_ data: Data, for key: String, accessibility: KeychainAccessibility) async throws -> Bool {
        // First try to update if item exists
        if await (try? self.retrieve(for: key)) != nil {
            return try await self.update(data, for: key)
        }

        // Create new item
        var query = self.createBaseQuery(for: key)
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = accessibility.cfString

        let status = SecItemAdd(query as CFDictionary, nil)

        switch status {
        case errSecSuccess:
            return true
        case errSecDuplicateItem:
            // Item was created between check and add, try update
            return try await self.update(data, for: key)
        default:
            throw KeychainError.operationFailed(status)
        }
    }

    func retrieve(for key: String) async throws -> Data? {
        var query = self.createBaseQuery(for: key)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainError.operationFailed(status)
        }
    }

    func update(_ data: Data, for key: String) async throws -> Bool {
        let query = self.createBaseQuery(for: key)
        let attributes: [String: Any] = [
            kSecValueData as String: data
        ]

        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)

        switch status {
        case errSecSuccess:
            return true
        case errSecItemNotFound:
            throw KeychainError.itemNotFound
        default:
            throw KeychainError.operationFailed(status)
        }
    }

    func delete(for key: String) async throws -> Bool {
        let query = self.createBaseQuery(for: key)
        let status = SecItemDelete(query as CFDictionary)

        switch status {
        case errSecSuccess, errSecItemNotFound:
            return true
        default:
            throw KeychainError.operationFailed(status)
        }
    }

    func deleteAll() async throws -> Bool {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.service
        ]

        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        let status = SecItemDelete(query as CFDictionary)

        switch status {
        case errSecSuccess, errSecItemNotFound:
            return true
        default:
            throw KeychainError.operationFailed(status)
        }
    }

    // MARK: - Private Methods

    private func createBaseQuery(for key: String) -> [String: Any] {
        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: self.service,
            kSecAttrAccount as String: key
        ]

        if let accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup
        }

        return query
    }
}

// MARK: - Keychain Migrator

/// Handles migration from insecure UserDefaults to secure Keychain storage
@available(iOS 15.0, *)
actor KeychainMigrator {
    private let keychain: KeychainServicing
    private let userDefaults: UserDefaults

    /// Keys that need to be migrated from UserDefaults
    private let keysToMigrate = ["user_email", "auth_token", "password"]

    init(keychain: KeychainServicing, userDefaults: UserDefaults = .standard) {
        self.keychain = keychain
        self.userDefaults = userDefaults
    }

    /// Migrates sensitive data from UserDefaults to Keychain
    /// - Throws: KeychainError if migration fails
    func migrateFromUserDefaults() async throws {
        var migratedKeys: [String] = []

        do {
            // Attempt to migrate each key
            for key in self.keysToMigrate {
                if let value = userDefaults.string(forKey: key),
                   let data = value.data(using: .utf8) {
                    _ = try await self.keychain.save(data, for: key, accessibility: .whenUnlockedThisDeviceOnly)
                    migratedKeys.append(key)
                }
            }

            // Only remove from UserDefaults if all migrations succeeded
            for key in migratedKeys {
                self.userDefaults.removeObject(forKey: key)
            }

            // Synchronize to ensure removal is persisted
            self.userDefaults.synchronize()

        } catch {
            // If migration fails, don't remove any data from UserDefaults
            throw KeychainError.migrationFailed("Failed to migrate keys: \(error.localizedDescription)")
        }
    }

    /// Checks if migration is needed
    /// - Returns: true if any sensitive data exists in UserDefaults
    func isMigrationNeeded() async -> Bool {
        for key in self.keysToMigrate where self.userDefaults.object(forKey: key) != nil {
            return true
        }
        return false
    }
}

// MARK: - Mock Implementation for Testing

@available(iOS 15.0, *)
actor MockKeychainService: KeychainServicing {
    private var storage: [String: Data] = [:]
    private var shouldFail = false
    var operationDelay: TimeInterval = 0

    func setShouldFail(_ value: Bool) {
        self.shouldFail = value
    }

    func save(_ data: Data, for key: String, accessibility _: KeychainAccessibility) async throws -> Bool {
        if self.operationDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(self.operationDelay * 1_000_000_000))
        }

        guard !self.shouldFail else {
            throw KeychainError.operationFailed(-1)
        }

        self.storage[key] = data
        return true
    }

    func retrieve(for key: String) async throws -> Data? {
        if self.operationDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(self.operationDelay * 1_000_000_000))
        }

        guard !self.shouldFail else {
            throw KeychainError.operationFailed(-1)
        }

        return self.storage[key]
    }

    func update(_ data: Data, for key: String) async throws -> Bool {
        if self.operationDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(self.operationDelay * 1_000_000_000))
        }

        guard !self.shouldFail else {
            throw KeychainError.operationFailed(-1)
        }

        guard self.storage[key] != nil else {
            throw KeychainError.itemNotFound
        }

        self.storage[key] = data
        return true
    }

    func delete(for key: String) async throws -> Bool {
        if self.operationDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(self.operationDelay * 1_000_000_000))
        }

        guard !self.shouldFail else {
            throw KeychainError.operationFailed(-1)
        }

        self.storage.removeValue(forKey: key)
        return true
    }

    func deleteAll() async throws -> Bool {
        if self.operationDelay > 0 {
            try await Task.sleep(nanoseconds: UInt64(self.operationDelay * 1_000_000_000))
        }

        guard !self.shouldFail else {
            throw KeychainError.operationFailed(-1)
        }

        self.storage.removeAll()
        return true
    }
}
