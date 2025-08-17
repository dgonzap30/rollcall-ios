//
// CreateRollViewModelCoreTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Combine
@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class CreateRollViewModelCoreTests: XCTestCase {
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

    // MARK: - Name Validation Tests

    func test_whenNameEmpty_shouldShowValidationError() {
        // Given
        self.sut.updateName("")

        // Then
        XCTAssertFalse(self.sut.viewState.isValid, "Empty name should make form invalid")
    }

    func test_whenNameTooShort_shouldShowValidationError() {
        // Given
        self.sut.updateName("A")

        // Then
        XCTAssertFalse(self.sut.viewState.isValid, "Name too short should make form invalid")
    }

    func test_whenNameTooLong_shouldShowValidationError() {
        // Given
        let longName = String(repeating: "a", count: 51)
        self.sut.updateName(longName)

        // Then
        XCTAssertFalse(self.sut.viewState.isValid, "Name too long should make form invalid")
    }

    func test_whenNameValid_shouldEnableForm() {
        // Given
        self.setupValidForm()

        // Then
        XCTAssertTrue(self.sut.viewState.isValid, "Valid name should enable form")
    }

    // MARK: - Rating Tests

    func test_whenRatingChanged_shouldTriggerHaptics() async {
        // Given
        self.mockHapticService.reset()

        // When
        self.sut.updateRating(4)

        // Give the async haptic call time to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        // Then
        XCTAssertTrue(self.mockHapticService.invokedImpact)
        XCTAssertEqual(self.mockHapticService.invokedImpactStyle, .light)
        XCTAssertEqual(self.sut.viewState.rating, 4)
    }

    func test_whenRatingOutOfRange_shouldIgnore() {
        // When
        self.sut.updateRating(0)

        // Then
        XCTAssertEqual(self.sut.viewState.rating, 3) // Default rating

        // When
        self.sut.updateRating(6)

        // Then
        XCTAssertEqual(self.sut.viewState.rating, 3) // Still default
    }

    // MARK: - Restaurant Selection Tests

    func test_whenRestaurantNotSelected_shouldDisableSave() {
        // Given
        self.sut.updateName("Valid Name")
        self.sut.updateRestaurant(nil)

        // Then
        XCTAssertFalse(self.sut.viewState.isValid, "Missing restaurant should disable save")
    }

    func test_whenRestaurantSelected_shouldEnableSave() {
        // Given
        self.setupValidForm()

        // Then
        XCTAssertTrue(self.sut.viewState.isValid, "Selected restaurant should enable save")
    }

    // MARK: - Edit Mode Tests

    func test_whenEditingExistingRoll_shouldPopulateFields() {
        // Given
        let existingRoll = self.createTestRoll()

        // When
        self.sut = CreateRollViewModel(
            rollRepository: self.mockRollRepository,
            chefRepository: self.mockChefRepository,
            restaurantRepository: self.mockRestaurantRepository,
            hapticService: self.mockHapticService,
            existingRoll: existingRoll
        )

        // Then
        XCTAssertEqual(self.sut.viewState.name, existingRoll.name)
        XCTAssertEqual(self.sut.viewState.rating, existingRoll.rating.value)
        XCTAssertEqual(self.sut.viewState.selectedType, existingRoll.type)
        XCTAssertTrue(self.sut.viewState.isEditing)
        XCTAssertEqual(self.sut.viewState.rollID, existingRoll.id)
    }

    // MARK: - Tags Tests

    func test_whenTagsUpdated_shouldParseCorrectly() {
        // When
        self.sut.updateTags("sushi, fresh, delicious, spicy")

        // Then
        XCTAssertEqual(self.sut.viewState.tags.count, 4)
        XCTAssertEqual(self.sut.viewState.tags[0], "sushi")
        XCTAssertEqual(self.sut.viewState.tags[1], "fresh")
        XCTAssertEqual(self.sut.viewState.tags[2], "delicious")
        XCTAssertEqual(self.sut.viewState.tags[3], "spicy")
    }

    func test_whenTooManyTags_shouldLimitToMax() {
        // Given
        let manyTags = (1...15).map { "tag\($0)" }.joined(separator: ", ")

        // When
        self.sut.updateTags(manyTags)

        // Then
        XCTAssertEqual(self.sut.viewState.tags.count, 10) // Max tag count
    }

    // MARK: - Empty State Tests

    func test_whenNameIsEmpty_shouldBeInvalid() {
        // Given
        self.sut.updateName("")
        self.sut.updateType(.nigiri)
        self.sut.updateRating(5)
        self.sut.updateRestaurant(self.createTestRestaurant())

        // Then
        XCTAssertFalse(self.sut.viewState.isValid)
    }

    func test_whenNameIsWhitespace_shouldBeInvalid() {
        // Given
        self.sut.updateName("   ")
        self.sut.updateType(.nigiri)
        self.sut.updateRating(5)
        self.sut.updateRestaurant(self.createTestRestaurant())

        // Then
        XCTAssertFalse(self.sut.viewState.isValid)
    }

    func test_whenRestaurantIsNil_shouldBeInvalid() {
        // Given
        self.sut.updateName("Test Roll")
        self.sut.updateType(.nigiri)
        self.sut.updateRating(5)
        self.sut.updateRestaurant(nil)

        // Then
        XCTAssertFalse(self.sut.viewState.isValid)
    }

    // MARK: - Helper Methods

    private func setupValidForm() {
        self.sut.updateName("Spicy Tuna Roll")
        self.sut.updateType(.maki)
        self.sut.updateRating(4)
        self.sut.updateRestaurant(self.createTestRestaurant())
    }

    private func createTestRoll() -> Roll {
        Roll(
            id: RollID(),
            chefID: ChefID(),
            restaurantID: RestaurantID(),
            type: .nigiri,
            name: "Salmon Nigiri",
            description: "Fresh salmon",
            rating: Rating(value: 5)!,
            photoURL: nil,
            tags: ["fresh", "salmon"],
            createdAt: Date(),
            updatedAt: Date()
        )
    }

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
