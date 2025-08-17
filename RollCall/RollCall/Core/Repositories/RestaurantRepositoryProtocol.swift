//
// RestaurantRepositoryProtocol.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

@available(iOS 15.0, *)
public protocol RestaurantRepositoryProtocol {
    func fetchAllRestaurants() async throws -> [Restaurant]
    func fetchRestaurant(by id: RestaurantID) async throws -> Restaurant?
    func createRestaurant(_ restaurant: Restaurant) async throws -> Restaurant
    func updateRestaurant(_ restaurant: Restaurant) async throws -> Restaurant
    func searchRestaurants(query: String) async throws -> [Restaurant]
}
