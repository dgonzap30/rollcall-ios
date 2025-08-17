//
// FeedMockRepository.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Foundation

@available(iOS 15.0, *)
public final class FeedMockRepository {
    // MARK: - Sample Data

    private let mockChefs: [Chef]
    private let mockRestaurants: [Restaurant]
    private var mockRolls: [Roll]
    private let chefIds: [ChefID]
    private let restaurantIds: [RestaurantID]

    public init() {
        // Initialize chefs using extracted data
        let chefData = MockChefData.createMockChefs()
        self.mockChefs = chefData.chefs
        self.chefIds = chefData.chefIds

        // Initialize restaurants using extracted data
        let restaurantData = MockRestaurantData.createMockRestaurants()
        self.mockRestaurants = restaurantData.restaurants
        self.restaurantIds = restaurantData.restaurantIds

        // Initialize rolls using extracted data
        self.mockRolls = MockRollData.createMockRolls(chefIds: self.chefIds, restaurantIds: self.restaurantIds)
    }

    // MARK: - Helper Methods

    public func getChefs() -> [Chef] {
        self.mockChefs
    }

    public func getRestaurants() -> [Restaurant] {
        self.mockRestaurants
    }

    public func getRolls() -> [Roll] {
        self.mockRolls
    }

    public func addRoll(_ roll: Roll) {
        self.mockRolls.insert(roll, at: 0)
    }

    // Generate more rolls for pagination testing
    public func generateAdditionalRolls(count: Int) -> [Roll] {
        var newRolls: [Roll] = []
        let baseDate = Date().addingTimeInterval(-30 * 24 * 60 * 60) // Start 30 days ago

        for index in 0..<count {
            let roll = MockRollData.generateAdditionalRoll(
                index: self.mockRolls.count + index,
                chefs: self.mockChefs,
                restaurants: self.mockRestaurants,
                baseDate: baseDate
            )
            newRolls.append(roll)
        }

        self.mockRolls.append(contentsOf: newRolls)
        return newRolls
    }
}
