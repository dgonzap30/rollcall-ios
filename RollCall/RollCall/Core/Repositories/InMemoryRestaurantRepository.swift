//
// InMemoryRestaurantRepository.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

// In-memory implementation for MVP
@available(iOS 15.0, *)
public actor InMemoryRestaurantRepository: RestaurantRepositoryProtocol {
    private var restaurants: [RestaurantID: Restaurant] = [:]

    public init(includeSampleData: Bool = true) {
        if includeSampleData {
            Task {
                await self.addSampleRestaurants()
            }
        }
    }

    public func fetchAllRestaurants() async throws -> [Restaurant] {
        Array(self.restaurants.values).sorted { $0.name < $1.name }
    }

    public func fetchRestaurant(by id: RestaurantID) async throws -> Restaurant? {
        self.restaurants[id]
    }

    public func createRestaurant(_ restaurant: Restaurant) async throws -> Restaurant {
        self.restaurants[restaurant.id] = restaurant
        return restaurant
    }

    public func updateRestaurant(_ restaurant: Restaurant) async throws -> Restaurant {
        guard self.restaurants[restaurant.id] != nil else {
            throw AppError.notFound("Restaurant not found")
        }
        self.restaurants[restaurant.id] = restaurant
        return restaurant
    }

    public func searchRestaurants(query: String) async throws -> [Restaurant] {
        let lowercasedQuery = query.lowercased()
        return self.restaurants.values.filter { restaurant in
            restaurant.name.lowercased().contains(lowercasedQuery) ||
                restaurant.cuisine.rawValue.lowercased().contains(lowercasedQuery)
        }
        .sorted { $0.name < $1.name }
    }

    private func addSampleRestaurants() {
        #if DEBUG
            let mockRepo = FeedMockRepository()
            for restaurant in mockRepo.getRestaurants() {
                self.restaurants[restaurant.id] = restaurant
            }
        #endif
    }
}
