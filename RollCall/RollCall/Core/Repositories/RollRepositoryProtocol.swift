//
// RollRepositoryProtocol.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

@available(iOS 15.0, *)
public protocol RollRepositoryProtocol {
    func fetchAllRolls() async throws -> [Roll]
    func fetchRoll(by id: RollID) async throws -> Roll?
    func createRoll(_ roll: Roll) async throws -> Roll
    func updateRoll(_ roll: Roll) async throws -> Roll
    func deleteRoll(by id: RollID) async throws
    func fetchRolls(for chefId: ChefID) async throws -> [Roll]

    /// Convenience method that either creates or updates a roll based on existence
    func save(_ roll: Roll) async throws -> Roll
}
