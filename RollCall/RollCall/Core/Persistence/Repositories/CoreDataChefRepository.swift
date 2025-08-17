//
// CoreDataChefRepository.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import CoreData
import Foundation

@available(iOS 15.0, *)
public final class CoreDataChefRepository: ChefRepositoryProtocol {
    // MARK: - Properties

    private let coreDataStack: CoreDataStack
    private let currentChefKey = "com.rollcall.currentChefId"

    // MARK: - Initialization

    public init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    // MARK: - ChefRepositoryProtocol

    public func fetchCurrentChef() async throws -> Chef? {
        guard let chefIdString = UserDefaults.standard.string(forKey: currentChefKey),
              let chefId = UUID(uuidString: chefIdString) else {
            return nil
        }

        let context = self.coreDataStack.viewContext
        let request: NSFetchRequest<ChefEntity> = ChefEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", chefId as CVarArg)
        request.fetchLimit = 1

        do {
            guard let entity = try context.fetch(request).first else {
                UserDefaults.standard.removeObject(forKey: self.currentChefKey)
                return nil
            }
            return entity.toDomainModel()
        } catch {
            throw AppError.database("Failed to fetch current chef: \(error.localizedDescription)")
        }
    }

    public func createChef(_ chef: Chef) async throws -> Chef {
        try await self.coreDataStack.performBackgroundTask { context in
            let entity = ChefEntity.from(chef, context: context)
            try self.coreDataStack.save(context: context)

            let hasCurrentChef = UserDefaults.standard.string(forKey: self.currentChefKey) != nil
            if !hasCurrentChef {
                UserDefaults.standard.set(chef.id.value.uuidString, forKey: self.currentChefKey)
            }

            return entity.toDomainModel()
        }
    }

    public func updateChef(_ chef: Chef) async throws -> Chef {
        try await self.coreDataStack.performBackgroundTask { context in
            let request: NSFetchRequest<ChefEntity> = ChefEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", chef.id.value as CVarArg)
            request.fetchLimit = 1

            guard let entity = try context.fetch(request).first else {
                throw AppError.notFound("Chef not found")
            }

            entity.update(from: chef)
            try self.coreDataStack.save(context: context)
            return entity.toDomainModel()
        }
    }

    public func fetchChef(by id: ChefID) async throws -> Chef? {
        let context = self.coreDataStack.viewContext
        let request: NSFetchRequest<ChefEntity> = ChefEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.value as CVarArg)
        request.fetchLimit = 1

        do {
            guard let entity = try context.fetch(request).first else { return nil }
            return entity.toDomainModel()
        } catch {
            throw AppError.database("Failed to fetch chef: \(error.localizedDescription)")
        }
    }

    // MARK: - Helper Methods

    public func setCurrentChef(_ chef: Chef) {
        UserDefaults.standard.set(chef.id.value.uuidString, forKey: self.currentChefKey)
    }

    public func clearCurrentChef() {
        UserDefaults.standard.removeObject(forKey: self.currentChefKey)
    }
}
