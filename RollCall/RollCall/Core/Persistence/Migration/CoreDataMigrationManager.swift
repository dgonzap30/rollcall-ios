//
// CoreDataMigrationManager.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import CoreData
import Foundation

@available(iOS 15.0, *)
public final class CoreDataMigrationManager {
    // MARK: - Properties

    private let modelName: String

    // MARK: - Initialization

    public init(modelName: String = "RollCall") {
        self.modelName = modelName
    }

    // MARK: - Migration

    public func requiresMigration(at storeURL: URL) -> Bool {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            return false
        }

        do {
            let metadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(
                ofType: NSSQLiteStoreType,
                at: storeURL,
                options: nil
            )

            guard let currentModel else {
                return false
            }

            return !currentModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata)
        } catch {
            print("Failed to check if migration is needed: \(error)")
            return false
        }
    }

    public func migrateStore(at storeURL: URL) throws {
        guard self.requiresMigration(at: storeURL) else { return }

        print("Migration required but not implemented. Using lightweight migration.")
    }

    // MARK: - Helpers

    private var currentModel: NSManagedObjectModel? {
        guard let modelURL = Bundle.main.url(forResource: modelName, withExtension: "momd") else {
            return nil
        }
        return NSManagedObjectModel(contentsOf: modelURL)
    }
}
