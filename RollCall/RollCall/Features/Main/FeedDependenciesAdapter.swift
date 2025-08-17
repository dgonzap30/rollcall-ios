//
// FeedDependenciesAdapter.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Foundation

@available(iOS 15.0, *)
struct FeedDependenciesAdapter: FeedCoordinator.Dependencies {
    private let container: Container

    init(container: Container) {
        self.container = container
    }

    var rollRepository: RollRepositoryProtocol {
        self.container.resolve(RollRepositoryProtocol.self)
    }

    var chefRepository: ChefRepositoryProtocol {
        self.container.resolve(ChefRepositoryProtocol.self)
    }

    var restaurantRepository: RestaurantRepositoryProtocol {
        self.container.resolve(RestaurantRepositoryProtocol.self)
    }

    var hapticService: HapticFeedbackServicing {
        self.container.resolve(HapticFeedbackServicing.self)
    }
}
