//
// CoreDataRestaurantRepository.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import CoreData
import Foundation

@available(iOS 15.0, *)
public final class CoreDataRestaurantRepository: RestaurantRepositoryProtocol {
    // MARK: - Properties

    private let coreDataStack: CoreDataStack
    private var hasLoadedSampleData = false

    // MARK: - Initialization

    public init(coreDataStack: CoreDataStack) {
        self.coreDataStack = coreDataStack
    }

    // MARK: - RestaurantRepositoryProtocol

    public func fetchAllRestaurants() async throws -> [Restaurant] {
        await self.loadSampleDataIfNeeded()

        let context = self.coreDataStack.viewContext
        let request: NSFetchRequest<RestaurantEntity> = RestaurantEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        do {
            let entities = try context.fetch(request)
            return try entities.map { try $0.toDomainModel() }
        } catch {
            throw AppError.database("Failed to fetch restaurants: \(error.localizedDescription)")
        }
    }

    public func fetchRestaurant(by id: RestaurantID) async throws -> Restaurant? {
        let context = self.coreDataStack.viewContext
        let request: NSFetchRequest<RestaurantEntity> = RestaurantEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id.value as CVarArg)
        request.fetchLimit = 1

        do {
            guard let entity = try context.fetch(request).first else { return nil }
            return try entity.toDomainModel()
        } catch {
            throw AppError.database("Failed to fetch restaurant: \(error.localizedDescription)")
        }
    }

    public func createRestaurant(_ restaurant: Restaurant) async throws -> Restaurant {
        try await self.coreDataStack.performBackgroundTask { context in
            let entity = RestaurantEntity.from(restaurant, context: context)
            try self.coreDataStack.save(context: context)
            return try entity.toDomainModel()
        }
    }

    public func updateRestaurant(_ restaurant: Restaurant) async throws -> Restaurant {
        try await self.coreDataStack.performBackgroundTask { context in
            let request: NSFetchRequest<RestaurantEntity> = RestaurantEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", restaurant.id.value as CVarArg)
            request.fetchLimit = 1

            guard let entity = try context.fetch(request).first else {
                throw AppError.notFound("Restaurant not found")
            }

            entity.update(from: restaurant)
            try self.coreDataStack.save(context: context)
            return try entity.toDomainModel()
        }
    }

    public func searchRestaurants(query: String) async throws -> [Restaurant] {
        await self.loadSampleDataIfNeeded()

        let context = self.coreDataStack.viewContext
        let request: NSFetchRequest<RestaurantEntity> = RestaurantEntity.fetchRequest()

        // If query is empty, return all restaurants
        if query.trimmingCharacters(in: .whitespaces).isEmpty {
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        } else {
            let namePredicate = NSPredicate(format: "name CONTAINS[cd] %@", query)
            let cuisinePredicate = NSPredicate(format: "cuisineType CONTAINS[cd] %@", query)
            request.predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [namePredicate, cuisinePredicate])
            request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        }

        do {
            let entities = try context.fetch(request)
            return try entities.map { try $0.toDomainModel() }
        } catch {
            throw AppError.database("Failed to search restaurants: \(error.localizedDescription)")
        }
    }

    /// Convenience method for searching restaurants
    public func search(query: String) async -> [Restaurant] {
        do {
            return try await self.searchRestaurants(query: query)
        } catch {
            // Log error and return empty array
            print("Restaurant search failed: \(error)")
            return []
        }
    }

    // MARK: - Sample Data

    private func loadSampleDataIfNeeded() async {
        guard !self.hasLoadedSampleData else { return }

        let context = self.coreDataStack.viewContext
        let request: NSFetchRequest<RestaurantEntity> = RestaurantEntity.fetchRequest()
        request.fetchLimit = 1

        do {
            let results = try context.fetch(request)
            if results.isEmpty {
                try await self.loadSampleData()
            }
            self.hasLoadedSampleData = true
        } catch {
            print("Failed to check restaurant count: \(error)")
        }
    }

    private func loadSampleData() async throws {
        let sampleRestaurants = self.createSampleRestaurants()

        for restaurant in sampleRestaurants {
            _ = try await self.createRestaurant(restaurant)
        }
    }

    private func createSampleRestaurants() -> [Restaurant] {
        [
            self.createSushiYasuda(),
            self.createNobuDowntown(),
            self.createSugarfish()
        ]
    }

    private func createSushiYasuda() -> Restaurant {
        Restaurant(
            id: RestaurantID(value: UUID()),
            name: "Sushi Yasuda",
            address: Address(
                street: "204 E 43rd St",
                city: "New York",
                state: "NY",
                postalCode: "10017",
                country: "USA"
            ),
            cuisine: .traditional,
            priceRange: .expensive,
            phoneNumber: "+1 212-972-1001",
            website: URL(string: "https://sushiyasuda.com"),
            coordinates: Coordinates(latitude: 40.7515, longitude: -73.9730),
            rating: 4.8,
            photoURLs: [],
            isOmakaseOffered: true,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    private func createNobuDowntown() -> Restaurant {
        Restaurant(
            id: RestaurantID(value: UUID()),
            name: "Nobu Downtown",
            address: Address(
                street: "195 Broadway",
                city: "New York",
                state: "NY",
                postalCode: "10007",
                country: "USA"
            ),
            cuisine: .fusion,
            priceRange: .expensive,
            phoneNumber: "+1 212-219-0500",
            website: URL(string: "https://noburestaurants.com"),
            coordinates: Coordinates(latitude: 40.7106, longitude: -74.0092),
            rating: 4.5,
            photoURLs: [],
            isOmakaseOffered: true,
            createdAt: Date(),
            updatedAt: Date()
        )
    }

    private func createSugarfish() -> Restaurant {
        Restaurant(
            id: RestaurantID(value: UUID()),
            name: "Sugarfish",
            address: Address(
                street: "33 E 20th St",
                city: "New York",
                state: "NY",
                postalCode: "10003",
                country: "USA"
            ),
            cuisine: .casual,
            priceRange: .moderate,
            phoneNumber: "+1 347-705-8100",
            website: URL(string: "https://sugarfish.com"),
            coordinates: Coordinates(latitude: 40.7389, longitude: -73.9875),
            rating: 4.2,
            photoURLs: [],
            isOmakaseOffered: false,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
