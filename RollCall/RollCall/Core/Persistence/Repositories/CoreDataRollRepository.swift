//
// CoreDataRollRepository.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import CoreData
import Foundation

@available(iOS 15.0, *)
public final class CoreDataRollRepository: RollRepositoryProtocol {
    // MARK: - Properties

    private let coreDataStack: CoreDataStack

    // MARK: - Initialization

    public init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    // MARK: - RollRepositoryProtocol

    public func fetchAllRolls() async throws -> [Roll] {
        let context = self.coreDataStack.viewContext
        let request: NSFetchRequest<RollEntity> = RollEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        request.relationshipKeyPathsForPrefetching = ["chef", "restaurant"]

        do {
            let entities = try context.fetch(request)
            return try entities.map { try $0.toDomainModel() }
        } catch {
            throw AppError.database("Failed to fetch rolls: \(error.localizedDescription)")
        }
    }

    public func fetchRoll(by id: RollID) async throws -> Roll? {
        let context = self.coreDataStack.viewContext
        let request: NSFetchRequest<RollEntity> = RollEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.value as CVarArg)
        request.fetchLimit = 1
        request.relationshipKeyPathsForPrefetching = ["chef", "restaurant"]

        do {
            guard let entity = try context.fetch(request).first else { return nil }
            return try entity.toDomainModel()
        } catch {
            throw AppError.database("Failed to fetch roll: \(error.localizedDescription)")
        }
    }

    public func createRoll(_ roll: Roll) async throws -> Roll {
        try await self.coreDataStack.performBackgroundTask { context in
            let rollEntity = RollEntity.from(roll, context: context)

            let chefRequest: NSFetchRequest<ChefEntity> = ChefEntity.fetchRequest()
            chefRequest.predicate = NSPredicate(format: "id == %@", roll.chefID.value as CVarArg)
            guard let chef = try context.fetch(chefRequest).first else {
                throw AppError.notFound("Chef not found")
            }
            rollEntity.chef = chef

            let restaurantRequest: NSFetchRequest<RestaurantEntity> = RestaurantEntity.fetchRequest()
            restaurantRequest.predicate = NSPredicate(format: "id == %@", roll.restaurantID.value as CVarArg)
            guard let restaurant = try context.fetch(restaurantRequest).first else {
                throw AppError.notFound("Restaurant not found")
            }
            rollEntity.restaurant = restaurant

            try self.coreDataStack.save(context: context)
            return try rollEntity.toDomainModel()
        }
    }

    public func updateRoll(_ roll: Roll) async throws -> Roll {
        try await self.coreDataStack.performBackgroundTask { context in
            let request: NSFetchRequest<RollEntity> = RollEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", roll.id.value as CVarArg)
            request.fetchLimit = 1

            guard let entity = try context.fetch(request).first else {
                throw AppError.notFound("Roll not found")
            }

            entity.update(from: roll)
            try self.coreDataStack.save(context: context)
            return try entity.toDomainModel()
        }
    }

    public func deleteRoll(by id: RollID) async throws {
        try await self.coreDataStack.performBackgroundTask { context in
            let request: NSFetchRequest<RollEntity> = RollEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", id.value as CVarArg)
            request.fetchLimit = 1

            guard let entity = try context.fetch(request).first else {
                throw AppError.notFound("Roll not found")
            }

            context.delete(entity)
            try self.coreDataStack.save(context: context)
        }
    }

    public func fetchRolls(for chefId: ChefID) async throws -> [Roll] {
        let context = self.coreDataStack.viewContext
        let request: NSFetchRequest<RollEntity> = RollEntity.fetchRequest()
        request.predicate = NSPredicate(format: "chef.id == %@", chefId.value as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        request.relationshipKeyPathsForPrefetching = ["chef", "restaurant"]

        do {
            let entities = try context.fetch(request)
            return try entities.map { try $0.toDomainModel() }
        } catch {
            throw AppError.database("Failed to fetch rolls for chef: \(error.localizedDescription)")
        }
    }

    public func save(_ roll: Roll) async throws -> Roll {
        // Check if roll exists
        if try await self.fetchRoll(by: roll.id) != nil {
            // Roll exists, update it
            try await self.updateRoll(roll)
        } else {
            // Roll doesn't exist, create it
            try await self.createRoll(roll)
        }
    }
}
