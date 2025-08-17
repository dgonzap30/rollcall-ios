//
// RestaurantServicing.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

// MARK: - Restaurant Service Protocol

@available(iOS 15.0, macOS 12.0, *)
protocol RestaurantServicing {
    func createRestaurant(_ restaurant: Restaurant) async throws -> Restaurant
    func updateRestaurant(_ restaurant: Restaurant) async throws -> Restaurant
    func getRestaurant(id: RestaurantID) async throws -> Restaurant
    func searchRestaurants(query: String, filters: RestaurantFilters?) async throws -> [Restaurant]
    func getNearbyRestaurants(coordinates: Coordinates, radius: Double) async throws -> [Restaurant]
    func getPopularRestaurants(limit: Int) async throws -> [Restaurant]
    func reportRestaurant(id: RestaurantID, reason: String) async throws
}

// MARK: - Restaurant Filters

@available(iOS 15.0, macOS 12.0, *)
struct RestaurantFilters {
    let cuisineTypes: [CuisineType]?
    let priceRanges: [PriceRange]?
    let hasOmakase: Bool?
    let minRating: Double?
    let maxDistance: Double?
}
