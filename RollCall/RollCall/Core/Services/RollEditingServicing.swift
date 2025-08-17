//
// RollEditingServicing.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Foundation

/// Protocol for managing roll editing and deletion operations
@available(iOS 15.0, *)
public protocol RollEditingServicing {
    /// Determines if the current user can edit the specified roll
    /// - Parameter roll: The roll to check edit permissions for
    /// - Returns: True if the user can edit the roll
    func canEditRoll(_ roll: Roll) async -> Bool

    /// Determines if the current user can delete the specified roll
    /// - Parameter roll: The roll to check delete permissions for
    /// - Returns: True if the user can delete the roll
    func canDeleteRoll(_ roll: Roll) async -> Bool

    /// Shows a confirmation dialog for deleting a roll
    /// - Parameter roll: The roll to be deleted
    /// - Returns: True if the user confirmed deletion
    func confirmDelete(for roll: Roll) async throws -> Bool

    /// Handles the result of editing a roll
    /// - Parameter result: The result of the edit operation
    func handleEditResult(_ result: CreateRollResult) async
}

/// Result of a roll creation or editing operation
@available(iOS 15.0, *)
public enum CreateRollResult {
    case saved(Roll)
    case cancelled
    case deleted(RollID)
}

/// Default implementation of RollEditingServicing
@available(iOS 15.0, *)
public final class RollEditingService: RollEditingServicing {
    private let chefRepository: ChefRepositoryProtocol
    private let rollRepository: RollRepositoryProtocol

    public init(
        chefRepository: ChefRepositoryProtocol,
        rollRepository: RollRepositoryProtocol
    ) {
        self.chefRepository = chefRepository
        self.rollRepository = rollRepository
    }

    public func canEditRoll(_ roll: Roll) async -> Bool {
        // In the future, check if the current user is the chef who created the roll
        // For now, allow editing all rolls in local-first mode
        do {
            let currentChef = try await chefRepository.fetchCurrentChef()
            return currentChef?.id == roll.chefID || currentChef == nil // Allow if no auth
        } catch {
            return true // Default to allowing edit in local mode
        }
    }

    public func canDeleteRoll(_ roll: Roll) async -> Bool {
        // Same logic as edit for now
        await self.canEditRoll(roll)
    }

    public func confirmDelete(for _: Roll) async throws -> Bool {
        // This would typically show a UIAlertController or SwiftUI confirmation
        // For now, return true as the UI will handle confirmation
        true
    }

    public func handleEditResult(_ result: CreateRollResult) async {
        // Handle any post-edit operations like analytics or sync
        switch result {
        case let .saved(roll):
            // Track analytics event
            print("Roll saved: \(roll.id)")
        case .cancelled:
            // Track cancellation
            print("Edit cancelled")
        case let .deleted(rollID):
            // Track deletion
            print("Roll deleted: \(rollID)")
        }
    }
}

// MARK: - Mock Implementation

#if DEBUG
    @available(iOS 15.0, *)
    public final class MockRollEditingService: RollEditingServicing {
        public var canEditResult = true
        public var canDeleteResult = true
        public var confirmDeleteResult = true

        public init() {}

        public func canEditRoll(_: Roll) async -> Bool {
            self.canEditResult
        }

        public func canDeleteRoll(_: Roll) async -> Bool {
            self.canDeleteResult
        }

        public func confirmDelete(for _: Roll) async throws -> Bool {
            self.confirmDeleteResult
        }

        public func handleEditResult(_: CreateRollResult) async {
            // No-op for mock
        }
    }
#endif
