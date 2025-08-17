//
// FeedMocks.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Foundation
@testable import RollCall

// MARK: - Mock Roll Repository

@available(iOS 15.0, *)
final class MockRollRepository: RollRepositoryProtocol {
    // Test compatibility properties
    var mockRolls: [Roll] = []
    var rolls: [Roll] {
        get { self.mockRolls }
        set { self.mockRolls = newValue }
    }

    var shouldThrowError = false

    // Invocation tracking
    var invokedFetchAllRolls = false
    var invokedFetchAllRollsCount = 0
    var stubbedFetchAllRollsResult: Result<[Roll], Error> = .success([])

    var invokedFetchRoll = false
    var invokedFetchRollParameters: RollID?
    var stubbedFetchRollResult: Roll?

    var invokedCreateRoll = false
    var invokedCreateRollParameters: Roll?
    var stubbedCreateRollResult: Result<Roll, Error>?

    var invokedUpdateRoll = false
    var invokedUpdateRollParameters: Roll?
    var stubbedUpdateRollResult: Result<Roll, Error>?

    var invokedDeleteRoll = false
    var invokedDeleteRollParameters: RollID?
    var stubbedDeleteRollError: Error?

    var invokedFetchRollsForChef = false
    var invokedFetchRollsForChefParameters: ChefID?
    var stubbedFetchRollsForChefResult: Result<[Roll], Error> = .success([])

    func fetchAllRolls() async throws -> [Roll] {
        self.invokedFetchAllRolls = true
        self.invokedFetchAllRollsCount += 1

        if self.shouldThrowError {
            throw AppError.network(URLError(.notConnectedToInternet))
        }

        // Use mockRolls if set, otherwise use stubbed result
        if !self.mockRolls.isEmpty {
            return self.mockRolls
        }

        switch self.stubbedFetchAllRollsResult {
        case let .success(rolls):
            return rolls
        case let .failure(error):
            throw error
        }
    }

    func fetchRoll(by id: RollID) async throws -> Roll? {
        self.invokedFetchRoll = true
        self.invokedFetchRollParameters = id
        return self.stubbedFetchRollResult
    }

    func createRoll(_ roll: Roll) async throws -> Roll {
        self.invokedCreateRoll = true
        self.invokedCreateRollParameters = roll

        if let result = stubbedCreateRollResult {
            switch result {
            case let .success(roll):
                return roll
            case let .failure(error):
                throw error
            }
        }
        return roll
    }

    func updateRoll(_ roll: Roll) async throws -> Roll {
        self.invokedUpdateRoll = true
        self.invokedUpdateRollParameters = roll

        if let result = stubbedUpdateRollResult {
            switch result {
            case let .success(roll):
                return roll
            case let .failure(error):
                throw error
            }
        }
        return roll
    }

    func deleteRoll(by id: RollID) async throws {
        self.invokedDeleteRoll = true
        self.invokedDeleteRollParameters = id

        if let error = stubbedDeleteRollError {
            throw error
        }
    }

    func fetchRolls(for chefId: ChefID) async throws -> [Roll] {
        self.invokedFetchRollsForChef = true
        self.invokedFetchRollsForChefParameters = chefId

        switch self.stubbedFetchRollsForChefResult {
        case let .success(rolls):
            return rolls
        case let .failure(error):
            throw error
        }
    }
}

// MARK: - Mock Chef Repository

@available(iOS 15.0, *)
final class MockChefRepository: ChefRepositoryProtocol {
    // Test compatibility properties
    var mockChefs: [Chef] = []
    var chefs: [Chef] {
        get { self.mockChefs }
        set { self.mockChefs = newValue }
    }

    var shouldThrowError = false

    var invokedFetchCurrentChef = false
    var stubbedFetchCurrentChefResult: Chef?

    var invokedCreateChef = false
    var invokedCreateChefParameters: Chef?
    var stubbedCreateChefResult: Result<Chef, Error>?

    var invokedUpdateChef = false
    var invokedUpdateChefParameters: Chef?
    var stubbedUpdateChefResult: Result<Chef, Error>?

    var invokedFetchChef = false
    var invokedFetchChefParameters: ChefID?
    var stubbedFetchChefResult: Chef?

    func fetchCurrentChef() async throws -> Chef? {
        self.invokedFetchCurrentChef = true
        return self.stubbedFetchCurrentChefResult
    }

    func createChef(_ chef: Chef) async throws -> Chef {
        self.invokedCreateChef = true
        self.invokedCreateChefParameters = chef

        if let result = stubbedCreateChefResult {
            switch result {
            case let .success(chef):
                return chef
            case let .failure(error):
                throw error
            }
        }
        return chef
    }

    func updateChef(_ chef: Chef) async throws -> Chef {
        self.invokedUpdateChef = true
        self.invokedUpdateChefParameters = chef

        if let result = stubbedUpdateChefResult {
            switch result {
            case let .success(chef):
                return chef
            case let .failure(error):
                throw error
            }
        }
        return chef
    }

    func fetchChef(by id: ChefID) async throws -> Chef? {
        self.invokedFetchChef = true
        self.invokedFetchChefParameters = id
        return self.stubbedFetchChefResult
    }
}

// MARK: - Mock Restaurant Repository

@available(iOS 15.0, *)
final class MockRestaurantRepository: RestaurantRepositoryProtocol {
    // Test compatibility properties
    var mockRestaurants: [Restaurant] = []
    var restaurants: [Restaurant] {
        get { self.mockRestaurants }
        set { self.mockRestaurants = newValue }
    }

    var shouldThrowError = false

    var invokedFetchAllRestaurants = false
    var stubbedFetchAllRestaurantsResult: Result<[Restaurant], Error> = .success([])

    var invokedFetchRestaurant = false
    var invokedFetchRestaurantParameters: RestaurantID?
    var stubbedFetchRestaurantResult: Restaurant?

    var invokedCreateRestaurant = false
    var invokedCreateRestaurantParameters: Restaurant?
    var stubbedCreateRestaurantResult: Result<Restaurant, Error>?

    var invokedUpdateRestaurant = false
    var invokedUpdateRestaurantParameters: Restaurant?
    var stubbedUpdateRestaurantResult: Result<Restaurant, Error>?

    var invokedSearchRestaurants = false
    var invokedSearchRestaurantsParameters: String?
    var stubbedSearchRestaurantsResult: Result<[Restaurant], Error> = .success([])

    func fetchAllRestaurants() async throws -> [Restaurant] {
        self.invokedFetchAllRestaurants = true

        if self.shouldThrowError {
            throw AppError.network(URLError(.notConnectedToInternet))
        }

        // Use mockRestaurants if set, otherwise use stubbed result
        if !self.mockRestaurants.isEmpty {
            return self.mockRestaurants
        }

        switch self.stubbedFetchAllRestaurantsResult {
        case let .success(restaurants):
            return restaurants
        case let .failure(error):
            throw error
        }
    }

    func fetchRestaurant(by id: RestaurantID) async throws -> Restaurant? {
        self.invokedFetchRestaurant = true
        self.invokedFetchRestaurantParameters = id
        return self.stubbedFetchRestaurantResult
    }

    func createRestaurant(_ restaurant: Restaurant) async throws -> Restaurant {
        self.invokedCreateRestaurant = true
        self.invokedCreateRestaurantParameters = restaurant

        if let result = stubbedCreateRestaurantResult {
            switch result {
            case let .success(restaurant):
                return restaurant
            case let .failure(error):
                throw error
            }
        }
        return restaurant
    }

    func updateRestaurant(_ restaurant: Restaurant) async throws -> Restaurant {
        self.invokedUpdateRestaurant = true
        self.invokedUpdateRestaurantParameters = restaurant

        if let result = stubbedUpdateRestaurantResult {
            switch result {
            case let .success(restaurant):
                return restaurant
            case let .failure(error):
                throw error
            }
        }
        return restaurant
    }

    func searchRestaurants(query: String) async throws -> [Restaurant] {
        self.invokedSearchRestaurants = true
        self.invokedSearchRestaurantsParameters = query

        switch self.stubbedSearchRestaurantsResult {
        case let .success(restaurants):
            return restaurants
        case let .failure(error):
            throw error
        }
    }
}
