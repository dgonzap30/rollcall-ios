//
// ChefRepositoryProtocol.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

@available(iOS 15.0, *)
public protocol ChefRepositoryProtocol {
    func fetchCurrentChef() async throws -> Chef?
    func createChef(_ chef: Chef) async throws -> Chef
    func updateChef(_ chef: Chef) async throws -> Chef
    func fetchChef(by id: ChefID) async throws -> Chef?
}
