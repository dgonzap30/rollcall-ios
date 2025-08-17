//
// KeychainServicing.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Foundation

// MARK: - Keychain Servicing Protocol

/// Protocol for secure storage of sensitive data using iOS Keychain
@available(iOS 15.0, *)
protocol KeychainServicing: Actor {
    /// Stores data securely in the keychain
    /// - Parameters:
    ///   - data: The data to store
    ///   - key: The unique identifier for this data
    ///   - accessibility: When the keychain item should be accessible
    /// - Returns: Success status
    /// - Throws: KeychainError if operation fails
    func save(_ data: Data, for key: String, accessibility: KeychainAccessibility) async throws -> Bool

    /// Retrieves data from the keychain
    /// - Parameter key: The unique identifier for the data
    /// - Returns: The stored data, or nil if not found
    /// - Throws: KeychainError if operation fails
    func retrieve(for key: String) async throws -> Data?

    /// Updates existing data in the keychain
    /// - Parameters:
    ///   - data: The new data to store
    ///   - key: The unique identifier for this data
    /// - Returns: Success status
    /// - Throws: KeychainError if operation fails
    func update(_ data: Data, for key: String) async throws -> Bool

    /// Removes data from the keychain
    /// - Parameter key: The unique identifier for the data
    /// - Returns: Success status
    /// - Throws: KeychainError if operation fails
    func delete(for key: String) async throws -> Bool

    /// Removes all data stored by this service
    /// - Returns: Success status
    /// - Throws: KeychainError if operation fails
    func deleteAll() async throws -> Bool
}

// MARK: - Keychain Accessibility Options

/// Defines when keychain items should be accessible
@available(iOS 15.0, *)
enum KeychainAccessibility {
    /// Item is accessible when device is unlocked
    case whenUnlocked
    /// Item is accessible when device is unlocked, and remains accessible until next restart
    case whenUnlockedThisDeviceOnly
    /// Item is accessible after first unlock until device restart
    case afterFirstUnlock
    /// Item is accessible after first unlock until device restart, this device only
    case afterFirstUnlockThisDeviceOnly

    var cfString: CFString {
        switch self {
        case .whenUnlocked:
            kSecAttrAccessibleWhenUnlocked
        case .whenUnlockedThisDeviceOnly:
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        case .afterFirstUnlock:
            kSecAttrAccessibleAfterFirstUnlock
        case .afterFirstUnlockThisDeviceOnly:
            kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        }
    }
}

// MARK: - Keychain Errors

/// Errors that can occur during keychain operations
@available(iOS 15.0, *)
enum KeychainError: LocalizedError {
    case itemNotFound
    case duplicateItem
    case invalidData
    case operationFailed(OSStatus)
    case migrationFailed(String)

    var errorDescription: String? {
        switch self {
        case .itemNotFound:
            "The requested item was not found in the keychain"
        case .duplicateItem:
            "An item with this key already exists"
        case .invalidData:
            "The data could not be processed"
        case let .operationFailed(status):
            "Keychain operation failed with status: \(status)"
        case let .migrationFailed(reason):
            "Keychain migration failed: \(reason)"
        }
    }
}

// MARK: - Keychain Item

/// Represents data stored in the keychain
@available(iOS 15.0, *)
struct KeychainItem {
    let key: String
    let data: Data
    let accessibility: KeychainAccessibility

    init(key: String, data: Data, accessibility: KeychainAccessibility = .whenUnlockedThisDeviceOnly) {
        self.key = key
        self.data = data
        self.accessibility = accessibility
    }
}
