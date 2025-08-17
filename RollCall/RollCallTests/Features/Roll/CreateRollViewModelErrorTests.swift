//
// CreateRollViewModelErrorTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Combine
@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class CreateRollViewModelErrorTests: XCTestCase {
    // MARK: - Properties

    private var sut: CreateRollViewModel!
    private var mockRollRepository: MockRollRepository!
    private var mockChefRepository: MockChefRepository!
    private var mockRestaurantRepository: MockRestaurantRepository!
    private var mockHapticService: MockHapticFeedbackService!
    private var mockDelegate: MockCreateRollViewModelDelegate!

    // MARK: - Setup & Teardown

    override func setUp() {
        super.setUp()

        self.mockRollRepository = MockRollRepository()
        self.mockChefRepository = MockChefRepository()
        self.mockRestaurantRepository = MockRestaurantRepository()
        self.mockHapticService = MockHapticFeedbackService()
        self.mockDelegate = MockCreateRollViewModelDelegate()

        self.sut = CreateRollViewModel(
            rollRepository: self.mockRollRepository,
            chefRepository: self.mockChefRepository,
            restaurantRepository: self.mockRestaurantRepository,
            hapticService: self.mockHapticService
        )
        self.sut.delegate = self.mockDelegate
    }

    override func tearDown() {
        self.sut = nil
        self.mockRollRepository = nil
        self.mockChefRepository = nil
        self.mockRestaurantRepository = nil
        self.mockHapticService = nil
        self.mockDelegate = nil
        super.tearDown()
    }

    // MARK: - Error Path Tests

    func test_whenSaveRollFails_shouldShowErrorState() async {
        // Given
        self.sut.updateName("Test Roll")
        self.sut.updateType(.nigiri)
        self.sut.updateRating(5)
        self.sut.updateRestaurant(self.createTestRestaurant())

        self.mockRollRepository.stubbedCreateRollResult = .failure(AppError.unknown)

        // When
        await self.sut.saveRoll()

        // Then
        XCTAssertNotNil(self.sut.viewState.errorMessage)
        XCTAssertTrue(self.mockHapticService.invokedNotification)
        XCTAssertEqual(self.mockHapticService.invokedNotificationType, .error)
    }

    func test_whenNetworkErrorOccurs_shouldShowNetworkErrorMessage() async {
        // Given
        self.sut.updateName("Test Roll")
        self.sut.updateType(.nigiri)
        self.sut.updateRating(5)
        self.sut.updateRestaurant(self.createTestRestaurant())

        self.mockRollRepository.stubbedCreateRollResult = .failure(AppError.networkError)

        // When
        await self.sut.saveRoll()

        // Then
        XCTAssertNotNil(self.sut.viewState.errorMessage)
        XCTAssertTrue(self.sut.viewState.errorMessage?.lowercased().contains("network") ?? false)
    }

    func test_whenValidationErrorOccurs_shouldShowValidationMessage() async {
        // Given
        self.sut.updateName("Test Roll")
        self.sut.updateType(.nigiri)
        self.sut.updateRating(5)
        self.sut.updateRestaurant(self.createTestRestaurant())

        self.mockRollRepository.stubbedCreateRollResult = .failure(AppError.validationError("Invalid roll data"))

        // When
        await self.sut.saveRoll()

        // Then
        XCTAssertNotNil(self.sut.viewState.errorMessage)
    }

    // MARK: - Rating Boundary Tests

    func test_whenRatingIsMinimum_shouldAcceptValidRating() {
        // Given & When
        self.sut.updateRating(1)

        // Then
        XCTAssertEqual(self.sut.viewState.rating, 1)
    }

    func test_whenRatingIsMaximum_shouldAcceptValidRating() {
        // Given & When
        self.sut.updateRating(5)

        // Then
        XCTAssertEqual(self.sut.viewState.rating, 5)
    }

    func test_whenRatingIsInvalid_shouldIgnore() {
        // Given
        self.sut.updateRating(3) // Set initial valid rating

        // When
        self.sut.updateRating(0) // Invalid rating

        // Then
        XCTAssertEqual(self.sut.viewState.rating, 3) // Should remain unchanged

        // When
        self.sut.updateRating(6) // Invalid rating

        // Then
        XCTAssertEqual(self.sut.viewState.rating, 3) // Should remain unchanged
    }

    // MARK: - Helper Methods

    private func createTestRestaurant() -> Restaurant {
        Restaurant(
            id: RestaurantID(),
            name: "Sushi Palace",
            address: Address(
                street: "123 Main St",
                city: "Tokyo",
                state: "Tokyo",
                postalCode: "100-0001",
                country: "Japan"
            ),
            cuisine: .traditional,
            priceRange: .moderate,
            phoneNumber: nil,
            website: nil,
            coordinates: Coordinates(latitude: 35.6762, longitude: 139.6503),
            rating: 4.5,
            photoURLs: [],
            isOmakaseOffered: true,
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

// MARK: - Mock Delegate

@available(iOS 15.0, *)
private final class MockCreateRollViewModelDelegate: CreateRollViewModelDelegate {
    var onSave: ((CreateRollViewModel, Roll) -> Void)?
    var onCancel: ((CreateRollViewModel) -> Void)?

    func createRollViewModelDidSave(_ viewModel: CreateRollViewModel, roll: Roll) {
        self.onSave?(viewModel, roll)
    }

    func createRollViewModelDidCancel(_ viewModel: CreateRollViewModel) {
        self.onCancel?(viewModel)
    }
}
