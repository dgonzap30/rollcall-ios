//
// AppSecurityMigrationService.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Foundation

// MARK: - App Security Migration Service

/// Service responsible for performing security-related migrations on app startup
@available(iOS 15.0, *)
actor AppSecurityMigrationService {
    private let keychain: KeychainServicing
    private let userDefaults: UserDefaults
    private let migrationKey = "security_migration_completed_v1"

    init(keychain: KeychainServicing? = nil, userDefaults: UserDefaults = .standard) {
        self.keychain = keychain ?? KeychainService()
        self.userDefaults = userDefaults
    }

    /// Performs all necessary security migrations
    /// Should be called on app startup before any auth operations
    func performMigrationsIfNeeded() async throws {
        // Check if migrations have already been completed
        guard !self.hasMigrationsCompleted() else {
            return
        }

        // Create migrator
        let migrator = KeychainMigrator(keychain: keychain, userDefaults: userDefaults)

        // Check if migration is needed
        if await migrator.isMigrationNeeded() {
            do {
                try await migrator.migrateFromUserDefaults()
                self.markMigrationsCompleted()
            } catch {
                // Log error but don't prevent app startup
                print("Security migration failed: \(error.localizedDescription)")
                // In production, this would be logged to crash reporting service
            }
        } else {
            // No migration needed, mark as completed
            self.markMigrationsCompleted()
        }
    }

    // MARK: - Private Methods

    private func hasMigrationsCompleted() -> Bool {
        self.userDefaults.bool(forKey: self.migrationKey)
    }

    private func markMigrationsCompleted() {
        self.userDefaults.set(true, forKey: self.migrationKey)
        self.userDefaults.synchronize()
    }
}
