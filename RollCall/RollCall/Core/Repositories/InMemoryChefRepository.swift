//
// InMemoryChefRepository.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

// In-memory implementation for MVP
@available(iOS 15.0, *)
public actor InMemoryChefRepository: ChefRepositoryProtocol {
    private var chefs: [ChefID: Chef] = [:]
    private var currentChefId: ChefID?

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
            for chef in mockRepo.getChefs() {
                self.chefs[chef.id] = chef
            }
            // Set first chef as current
            self.currentChefId = mockRepo.getChefs().first?.id
        }
    #endif

    public func fetchCurrentChef() async throws -> Chef? {
        if let currentId = currentChefId,
           let chef = chefs[currentId] {
            return chef
        }
        return nil
    }

    public func createChef(_ chef: Chef) async throws -> Chef {
        self.chefs[chef.id] = chef
        // Set as current chef if none exists
        if self.currentChefId == nil {
            self.currentChefId = chef.id
        }
        return chef
    }

    public func updateChef(_ chef: Chef) async throws -> Chef {
        guard self.chefs[chef.id] != nil else {
            throw AppError.notFound("Chef not found")
        }
        self.chefs[chef.id] = chef
        return chef
    }

    public func fetchChef(by id: ChefID) async throws -> Chef? {
        self.chefs[id]
    }
}
