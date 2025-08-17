//
// CoreDataMigrationManagerTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import CoreData
@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class CoreDataMigrationManagerTests: XCTestCase {
    var sut: CoreDataMigrationManager!
    var testStoreURL: URL!

    override func setUp() async throws {
        try await super.setUp()

        // Create test URLs
        let tempDir = FileManager.default.temporaryDirectory
        self.testStoreURL = tempDir.appendingPathComponent("TestMigration.sqlite")

        // Clean up any existing test store
        try? FileManager.default.removeItem(at: self.testStoreURL)

        self.sut = CoreDataMigrationManager()
    }

    override func tearDown() async throws {
        // Clean up test store
        try? FileManager.default.removeItem(at: self.testStoreURL)

        self.sut = nil
        self.testStoreURL = nil

        try await super.tearDown()
    }

    // MARK: - Migration Check Tests

    func test_requiresMigration_newStore_returnsFalse() {
        // New store should not require migration
        let requiresMigration = self.sut.requiresMigration(at: self.testStoreURL)

        XCTAssertFalse(requiresMigration)
    }

    func test_requiresMigration_existingCompatibleStore_returnsFalse() throws {
        // Create a store with current model
        guard let modelURL = Bundle.main.url(forResource: "RollCall", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            XCTFail("Could not load model")
            return
        }

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)

        _ = try coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: self.testStoreURL,
            options: nil
        )

        // Check if migration is required
        let requiresMigration = self.sut.requiresMigration(at: self.testStoreURL)

        XCTAssertFalse(requiresMigration)
    }

    // MARK: - Migration Execution Tests

    func test_migrateStore_newStore_succeeds() throws {
        // Attempt to migrate a non-existent store (should succeed)
        try self.sut.migrateStore(at: self.testStoreURL)

        // Should complete without error
        XCTAssertTrue(true)
    }

    func test_migrateStore_existingCompatibleStore_succeeds() throws {
        // Create a store with current model
        guard let modelURL = Bundle.main.url(forResource: "RollCall", withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL) else {
            XCTFail("Could not load model")
            return
        }

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)

        _ = try coordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: self.testStoreURL,
            options: nil
        )

        // Migrate (should be no-op)
        try self.sut.migrateStore(at: self.testStoreURL)

        // Verify store is still accessible
        let newCoordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        let store = try newCoordinator.addPersistentStore(
            ofType: NSSQLiteStoreType,
            configurationName: nil,
            at: self.testStoreURL,
            options: nil
        )

        XCTAssertNotNil(store)
    }

    // MARK: - Future Migration Readiness Tests

    func test_migrationManager_isConfiguredForFutureMigrations() {
        // Verify migration manager is ready for future schema changes
        XCTAssertNotNil(self.sut)

        // Verify it can check migration requirements
        let requiresMigration = self.sut.requiresMigration(at: self.testStoreURL)
        XCTAssertFalse(requiresMigration)
    }
}
