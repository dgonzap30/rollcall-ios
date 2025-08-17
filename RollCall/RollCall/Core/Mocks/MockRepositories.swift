//
// MockRepositories.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

// MARK: - Mock Roll Repository

@available(iOS 15.0, *)
public final class MockRollRepository: RollRepositoryProtocol {
    public var shouldThrowError = false
    public var mockRolls: [Roll] = []
    // Alias for test compatibility
    public var rolls: [Roll] {
        get { self.mockRolls }
        set { self.mockRolls = newValue }
    }

    public var createCallCount = 0
    public var updateCallCount = 0
    public var deleteCallCount = 0

    // Test helpers for async tests
    public var stubbedCreateRollResult: Result<Roll, Error>?
    public var invokedCreateRoll = false

    public init() {
        self.setupMockData()
    }

    public func fetchAllRolls() async throws -> [Roll] {
        if self.shouldThrowError {
            throw AppError.networkError
        }
        return self.mockRolls
    }

    public func fetchRoll(by id: RollID) async throws -> Roll? {
        if self.shouldThrowError {
            throw AppError.networkError
        }
        return self.mockRolls.first { $0.id == id }
    }

    public func createRoll(_ roll: Roll) async throws -> Roll {
        self.invokedCreateRoll = true

        // Check for stubbed result first
        if let stubbedResult = stubbedCreateRollResult {
            switch stubbedResult {
            case let .success(roll):
                self.createCallCount += 1
                self.mockRolls.append(roll)
                return roll
            case let .failure(error):
                throw error
            }
        }

        if self.shouldThrowError {
            throw AppError.networkError
        }
        self.createCallCount += 1
        self.mockRolls.append(roll)
        return roll
    }

    public func updateRoll(_ roll: Roll) async throws -> Roll {
        if self.shouldThrowError {
            throw AppError.networkError
        }
        self.updateCallCount += 1
        if let index = mockRolls.firstIndex(where: { $0.id == roll.id }) {
            self.mockRolls[index] = roll
            return roll
        }
        throw AppError.notFound("Roll not found")
    }

    public func deleteRoll(by id: RollID) async throws {
        if self.shouldThrowError {
            throw AppError.networkError
        }
        self.deleteCallCount += 1
        self.mockRolls.removeAll { $0.id == id }
    }

    public func fetchRolls(for chefId: ChefID) async throws -> [Roll] {
        if self.shouldThrowError {
            throw AppError.networkError
        }
        return self.mockRolls.filter { $0.chefID == chefId }
    }

    public func save(_ roll: Roll) async throws -> Roll {
        if self.shouldThrowError {
            throw AppError.networkError
        }
        if let index = mockRolls.firstIndex(where: { $0.id == roll.id }) {
            // Roll exists, update it
            self.updateCallCount += 1
            self.mockRolls[index] = roll
            return roll
        } else {
            // Roll doesn't exist, create it
            self.createCallCount += 1
            self.mockRolls.append(roll)
            return roll
        }
    }

    private func setupMockData() {
        let chefId = ChefID()
        let restaurantId = RestaurantID()
        self.mockRolls = SampleData.createSampleRolls(chefId: chefId, restaurantId: restaurantId)
    }
}

// MARK: - Mock Chef Repository

@available(iOS 15.0, *)
public final class MockChefRepository: ChefRepositoryProtocol {
    public var shouldThrowError = false
    public var mockChef: Chef?
    // Array for test compatibility
    public var chefs: [Chef] = []

    public init() {
        self.setupMockData()
    }

    public func fetchCurrentChef() async throws -> Chef? {
        if self.shouldThrowError {
            throw AppError.networkError
        }
        // Return first chef from array if available, otherwise mockChef
        return self.chefs.first ?? self.mockChef
    }

    public func createChef(_ chef: Chef) async throws -> Chef {
        if self.shouldThrowError {
            throw AppError.networkError
        }
        self.mockChef = chef
        return chef
    }

    public func updateChef(_ chef: Chef) async throws -> Chef {
        if self.shouldThrowError {
            throw AppError.networkError
        }
        self.mockChef = chef
        return chef
    }

    public func fetchChef(by id: ChefID) async throws -> Chef? {
        if self.shouldThrowError {
            throw AppError.networkError
        }
        // Search in chefs array first, then mockChef
        if let chef = chefs.first(where: { $0.id == id }) {
            return chef
        }
        return self.mockChef?.id == id ? self.mockChef : nil
    }

    private func setupMockData() {
        self.mockChef = SampleData.createSampleChef()
    }
}

// MARK: - Mock Restaurant Repository

@available(iOS 15.0, *)
public final class MockRestaurantRepository: RestaurantRepositoryProtocol {
    public var shouldThrowError = false
    public var mockRestaurants: [Restaurant] = []
    // Alias for test compatibility
    public var restaurants: [Restaurant] {
        get { self.mockRestaurants }
        set { self.mockRestaurants = newValue }
    }

    public init() {
        self.setupMockData()
    }

    public func fetchAllRestaurants() async throws -> [Restaurant] {
        if self.shouldThrowError {
            throw AppError.networkError
        }
        return self.mockRestaurants
    }

    public func fetchRestaurant(by id: RestaurantID) async throws -> Restaurant? {
        if self.shouldThrowError {
            throw AppError.networkError
        }
        return self.mockRestaurants.first { $0.id == id }
    }

    public func createRestaurant(_ restaurant: Restaurant) async throws -> Restaurant {
        if self.shouldThrowError {
            throw AppError.networkError
        }
        self.mockRestaurants.append(restaurant)
        return restaurant
    }

    public func updateRestaurant(_ restaurant: Restaurant) async throws -> Restaurant {
        if self.shouldThrowError {
            throw AppError.networkError
        }
        if let index = mockRestaurants.firstIndex(where: { $0.id == restaurant.id }) {
            self.mockRestaurants[index] = restaurant
            return restaurant
        }
        throw AppError.notFound("Restaurant not found")
    }

    public func searchRestaurants(query: String) async throws -> [Restaurant] {
        if self.shouldThrowError {
            throw AppError.networkError
        }
        let lowercasedQuery = query.lowercased()
        return self.mockRestaurants.filter { restaurant in
            restaurant.name.lowercased().contains(lowercasedQuery) ||
                restaurant.cuisine.rawValue.lowercased().contains(lowercasedQuery)
        }
    }

    private func setupMockData() {
        self.mockRestaurants = SampleData.createSampleRestaurants()
    }
}
