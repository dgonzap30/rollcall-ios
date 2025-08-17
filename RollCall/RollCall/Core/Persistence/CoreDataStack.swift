//
// CoreDataStack.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import CoreData
import Foundation

@available(iOS 15.0, *)
public final class CoreDataStack {
    // MARK: - Properties

    private let modelName: String
    private let inMemory: Bool

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: modelName)

        if self.inMemory {
            let description = NSPersistentStoreDescription()
            description.type = NSInMemoryStoreType
            description.shouldAddStoreAsynchronously = false
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                assertionFailure("Core Data failed to load: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    public var viewContext: NSManagedObjectContext {
        self.persistentContainer.viewContext
    }

    // MARK: - Initialization

    public init(modelName: String = "RollCall", inMemory: Bool = false) {
        self.modelName = modelName
        self.inMemory = inMemory
    }

    // MARK: - Core Data Operations

    public func performBackgroundTask<T>(
        _ block: @escaping (NSManagedObjectContext) async throws -> T
    ) async throws -> T {
        try await withCheckedThrowingContinuation { continuation in
            self.persistentContainer.performBackgroundTask { context in
                Task {
                    do {
                        let result = try await block(context)
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }

    public func save(context: NSManagedObjectContext) throws {
        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            throw AppError.database("Failed to save context: \(nsError.localizedDescription)")
        }
    }

    // MARK: - Migration Support

    public func deleteAllData() async throws {
        let entityNames = self.persistentContainer.managedObjectModel.entities.compactMap(\.name)

        try await self.performBackgroundTask { context in
            for entityName in entityNames {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                try context.execute(deleteRequest)
            }
            try self.save(context: context)
        }
    }

    // MARK: - Testing Support

    public static func makeTestStack() -> CoreDataStack {
        CoreDataStack(modelName: "RollCall", inMemory: true)
    }

    deinit {
        #if DEBUG
            print("[CoreDataStack] deinit")
        #endif
    }
}
