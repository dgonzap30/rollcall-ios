//
// FeedDataPreloader.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Foundation

@available(iOS 15.0, *)
enum FeedDataPreloader {
    static func preloadDataForRolls(
        _ rolls: [Roll],
        chefCache: [ChefID: Chef],
        restaurantCache: [RestaurantID: Restaurant],
        chefRepository: ChefRepositoryProtocol,
        restaurantRepository: RestaurantRepositoryProtocol
    ) async -> (chefCache: [ChefID: Chef], restaurantCache: [RestaurantID: Restaurant]) {
        let uniqueChefIds = Set(rolls.map(\.chefID))
        let uniqueRestaurantIds = Set(rolls.map(\.restaurantID))

        var updatedChefCache = chefCache
        var updatedRestaurantCache = restaurantCache

        await preloadChefs(
            uniqueChefIds,
            chefCache: &updatedChefCache,
            chefRepository: chefRepository
        )
        await self.preloadRestaurants(
            uniqueRestaurantIds,
            restaurantCache: &updatedRestaurantCache,
            restaurantRepository: restaurantRepository
        )

        return (chefCache: updatedChefCache, restaurantCache: updatedRestaurantCache)
    }

    private static func preloadChefs(
        _ chefIds: Set<ChefID>,
        chefCache: inout [ChefID: Chef],
        chefRepository: ChefRepositoryProtocol
    ) async {
        await withTaskGroup(of: (ChefID, Chef?).self) { group in
            for chefId in chefIds where chefCache[chefId] == nil {
                group.addTask {
                    let chef = try? await chefRepository.fetchChef(by: chefId)
                    return (chefId, chef)
                }
            }

            for await (chefId, chef) in group {
                if let chef {
                    chefCache[chefId] = chef
                }
            }
        }
    }

    private static func preloadRestaurants(
        _ restaurantIds: Set<RestaurantID>,
        restaurantCache: inout [RestaurantID: Restaurant],
        restaurantRepository: RestaurantRepositoryProtocol
    ) async {
        await withTaskGroup(of: (RestaurantID, Restaurant?).self) { group in
            for restaurantId in restaurantIds where restaurantCache[restaurantId] == nil {
                group.addTask {
                    let restaurant = try? await restaurantRepository.fetchRestaurant(by: restaurantId)
                    return (restaurantId, restaurant)
                }
            }

            for await (restaurantId, restaurant) in group {
                if let restaurant {
                    restaurantCache[restaurantId] = restaurant
                }
            }
        }
    }
}
