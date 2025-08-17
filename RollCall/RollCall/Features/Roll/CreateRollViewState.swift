//
// CreateRollViewState.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Foundation

@available(iOS 15.0, *)
public struct CreateRollViewState: Equatable {
    // MARK: - Form Fields

    public var name: String = ""
    public var selectedType: RollType = .nigiri
    public var rating: Int = 3
    public var description: String = ""
    public var selectedRestaurant: Restaurant?
    public var tags: [String] = []

    // MARK: - UI State

    public var isValid: Bool = false
    public var isSaving: Bool = false
    public var isLoadingRestaurants: Bool = false
    public var errorMessage: String?
    public var availableRestaurants: [Restaurant] = []

    // MARK: - Edit Mode

    public var isEditing: Bool = false
    public var rollID: RollID?

    // MARK: - Initialization

    public init() {}

    public init(from roll: Roll) {
        self.name = roll.name
        self.selectedType = roll.type
        self.rating = roll.rating.value
        self.description = roll.description ?? ""
        self.tags = roll.tags
        self.isEditing = true
        self.rollID = roll.id
        // Restaurant will be loaded separately
    }
}

// MARK: - Validation Errors

@available(iOS 15.0, *)
public enum CreateRollValidationError: String, LocalizedError {
    case nameRequired = "Roll name is required"
    case restaurantRequired = "Restaurant name is required"
    case ratingOutOfRange = "Rating must be between 1-5"

    public var errorDescription: String? {
        rawValue
    }
}

// MARK: - Navigation Events

@available(iOS 15.0, *)
public enum CreateRollNavigationEvent {
    case dismissRequested
    case saveCompleted(Roll)
    case deleteCompleted
}
