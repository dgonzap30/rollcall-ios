//
// InMemoryRollRepository.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

// In-memory implementation for MVP
@available(iOS 15.0, *)
public actor InMemoryRollRepository: RollRepositoryProtocol {
    private var rolls: [RollID: Roll] = [:]

    public init() {
        // Initialize with mock data for development
        #if DEBUG
            Task {
                await self.initializeMockData()
            }
        #endif
    }

    #if DEBUG
        private func initializeMockData() async {
            let mockRepo = FeedMockRepository()
            // Generate additional rolls for pagination testing
            _ = mockRepo.generateAdditionalRolls(count: 30)

            for roll in mockRepo.getRolls() {
                self.rolls[roll.id] = roll
            }
        }
    #endif

    public func fetchAllRolls() async throws -> [Roll] {
        Array(self.rolls.values).sorted { $0.createdAt > $1.createdAt }
    }

    public func fetchRoll(by id: RollID) async throws -> Roll? {
        self.rolls[id]
    }

    public func createRoll(_ roll: Roll) async throws -> Roll {
        self.rolls[roll.id] = roll
        return roll
    }

    public func updateRoll(_ roll: Roll) async throws -> Roll {
        guard self.rolls[roll.id] != nil else {
            throw AppError.notFound("Roll not found")
        }
        self.rolls[roll.id] = roll
        return roll
    }

    public func deleteRoll(by id: RollID) async throws {
        guard self.rolls.removeValue(forKey: id) != nil else {
            throw AppError.notFound("Roll not found")
        }
    }

    public func fetchRolls(for chefId: ChefID) async throws -> [Roll] {
        self.rolls.values
            .filter { $0.chefID == chefId }
            .sorted { $0.createdAt > $1.createdAt }
    }

    public func save(_ roll: Roll) async throws -> Roll {
        if self.rolls[roll.id] != nil {
            // Roll exists, update it
            try await self.updateRoll(roll)
        } else {
            // Roll doesn't exist, create it
            try await self.createRoll(roll)
        }
    }
}
