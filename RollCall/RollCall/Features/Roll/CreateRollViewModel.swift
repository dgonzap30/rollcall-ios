//
// CreateRollViewModel.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Combine
import Foundation

@available(iOS 15.0, *)
public protocol CreateRollViewModelDelegate: AnyObject {
    func createRollViewModelDidSave(_ viewModel: CreateRollViewModel, roll: Roll)
    func createRollViewModelDidCancel(_ viewModel: CreateRollViewModel)
}

@available(iOS 15.0, *)
public final class CreateRollViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published private(set) var viewState: CreateRollViewState

    // MARK: - Dependencies

    private let rollRepository: RollRepositoryProtocol
    private let chefRepository: ChefRepositoryProtocol
    private let restaurantRepository: RestaurantRepositoryProtocol
    private let hapticService: HapticFeedbackServicing

    public weak var delegate: CreateRollViewModelDelegate?

    // MARK: - Private Properties

    private var saveTask: Task<Void, Never>?
    private var loadTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization

    public init(
        rollRepository: RollRepositoryProtocol,
        chefRepository: ChefRepositoryProtocol,
        restaurantRepository: RestaurantRepositoryProtocol,
        hapticService: HapticFeedbackServicing,
        existingRoll: Roll? = nil
    ) {
        self.rollRepository = rollRepository
        self.chefRepository = chefRepository
        self.restaurantRepository = restaurantRepository
        self.hapticService = hapticService

        if let roll = existingRoll {
            self.viewState = CreateRollViewState(from: roll)
        } else {
            self.viewState = CreateRollViewState()
        }

        self.loadRestaurants()
    }

    deinit {
        saveTask?.cancel()
        loadTask?.cancel()
    }

    // MARK: - Public Methods

    public func updateName(_ name: String) {
        self.viewState.name = name
        self.validateForm()
    }

    public func updateType(_ type: RollType) {
        self.viewState.selectedType = type
    }

    public func updateRating(_ rating: Int) {
        guard (1...5).contains(rating) else { return }
        self.viewState.rating = rating
        Task { [weak self] in
            await self?.hapticService.impact(style: .light)
        }
    }

    public func updateDescription(_ description: String) {
        self.viewState.description = description
    }

    public func updateRestaurant(_ restaurant: Restaurant?) {
        self.viewState.selectedRestaurant = restaurant
        self.validateForm()
    }

    public func updateTags(_ tags: String) {
        self.viewState.tags = tags.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .prefix(CreateRollConstants.Validation.maxTagCount)
            .map { String($0.prefix(CreateRollConstants.Validation.maxTagLength)) }
    }

    public func saveRoll() {
        guard self.viewState.isValid else { return }

        self.saveTask?.cancel()
        self.saveTask = Task { [weak self] in
            await self?.performSave()
        }
    }

    public func cancel() {
        Task { [weak self] in
            await self?.hapticService.impact(style: .light)
        }
        self.delegate?.createRollViewModelDidCancel(self)
    }

    // MARK: - Private Methods

    private func loadRestaurants() {
        self.loadTask?.cancel()
        self.loadTask = Task { [weak self] in
            guard let self else { return }

            await MainActor.run {
                self.viewState.isLoadingRestaurants = true
            }

            do {
                let restaurants = try await restaurantRepository.fetchAllRestaurants()
                await MainActor.run {
                    self.viewState.availableRestaurants = restaurants
                    self.viewState.isLoadingRestaurants = false
                }
            } catch {
                await MainActor.run {
                    self.viewState.errorMessage = "Failed to load restaurants"
                    self.viewState.isLoadingRestaurants = false
                }
            }
        }
    }

    @MainActor
    private func performSave() async {
        self.viewState.isSaving = true
        self.viewState.errorMessage = nil

        do {
            // Get current chef (in real app, from auth service)
            // For now, use the current chef or create a default one
            let currentChef = try await chefRepository.fetchCurrentChef()
            let chefID = currentChef?.id ?? ChefID()

            guard let restaurant = viewState.selectedRestaurant,
                  let rating = Rating(value: viewState.rating) else {
                self.viewState.errorMessage = "Invalid form data"
                self.viewState.isSaving = false
                return
            }

            let roll = Roll(
                id: viewState.rollID ?? RollID(),
                chefID: chefID,
                restaurantID: restaurant.id,
                type: self.viewState.selectedType,
                name: self.viewState.name,
                description: self.viewState.description.isEmpty ? nil : self.viewState.description,
                rating: rating,
                photoURL: nil, // Photo upload in future iteration
                tags: self.viewState.tags,
                createdAt: self.viewState.isEditing ? Date() : Date(), // Keep original if editing
                updatedAt: Date()
            )

            let savedRoll: Roll = if self.viewState.isEditing {
                try await self.rollRepository.updateRoll(roll)
            } else {
                try await self.rollRepository.createRoll(roll)
            }

            await self.hapticService.notification(type: .success)
            self.viewState.isSaving = false

            self.delegate?.createRollViewModelDidSave(self, roll: savedRoll)

        } catch {
            self.viewState.errorMessage = "Failed to save roll: \(error.localizedDescription)"
            self.viewState.isSaving = false
            await self.hapticService.notification(type: .error)
        }
    }

    private func validateForm() {
        let nameValid = !self.viewState.name.trimmingCharacters(in: .whitespaces).isEmpty &&
            self.viewState.name.count >= CreateRollConstants.Validation.minNameLength &&
            self.viewState.name.count <= CreateRollConstants.Validation.maxNameLength

        let restaurantValid = self.viewState.selectedRestaurant != nil
        let ratingValid = (1...5).contains(self.viewState.rating)

        self.viewState.isValid = nameValid && restaurantValid && ratingValid
    }
}
