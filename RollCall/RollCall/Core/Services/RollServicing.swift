//
// RollServicing.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

// MARK: - Roll Service Protocol

@available(iOS 15.0, macOS 12.0, *)
protocol RollServicing {
    func createRoll(_ roll: Roll) async throws -> Roll
    func updateRoll(_ roll: Roll) async throws -> Roll
    func deleteRoll(id: RollID) async throws
    func getRoll(id: RollID) async throws -> Roll
    func fetchRolls(for chef: ChefID, limit: Int, offset: Int) async throws -> [Roll]
    func fetchFeed(limit: Int, offset: Int) async throws -> [Roll]
    func searchRolls(query: String, filters: RollFilters?) async throws -> [Roll]
    func getRollStats(for chef: ChefID) async throws -> RollStats
}

// MARK: - Roll Filters

@available(iOS 15.0, macOS 12.0, *)
struct RollFilters {
    let types: [RollType]?
    let minRating: Rating?
    let maxRating: Rating?
    let restaurantIDs: [RestaurantID]?
    let dateRange: DateRange?
    let tags: [String]?
}

// MARK: - Date Range

@available(iOS 15.0, macOS 12.0, *)
struct DateRange {
    let start: Date
    let end: Date
}

// MARK: - Roll Stats

@available(iOS 15.0, macOS 12.0, *)
struct RollStats {
    let totalRolls: Int
    let averageRating: Double
    let typeDistribution: [RollType: Int]
    let favoriteRestaurant: Restaurant?
    let monthlyCount: Int
}
