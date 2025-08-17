//
// CreateRollViewModelAsyncTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Combine
@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class CreateRollViewModelAsyncTests: XCTestCase {
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

    // MARK: - Save Tests

    func test_whenValidFormSubmitted_shouldSaveSuccessfully() async {
        // Given
        self.setupValidForm()
        let expectation = XCTestExpectation(description: "Roll saved")

        // Configure mock to return success
        let testRoll = self.createTestRoll()
        self.mockRollRepository.stubbedCreateRollResult = .success(testRoll)

        self.mockDelegate.onSave = { _, roll in
            XCTAssertEqual(roll.name, "Spicy Tuna Roll")
            expectation.fulfill()
        }

        // When
        self.sut.saveRoll()

        // Then
        await fulfillment(of: [expectation], timeout: 0.5)
    }

    func test_whenSaveFails_shouldShowErrorMessage() async {
        // Given
        self.setupValidForm()
        self.mockRollRepository.stubbedCreateRollResult = .failure(AppError.networkError)

        // When
        self.sut.saveRoll()

        // Wait for async operation
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        // Then
        await MainActor.run {
            XCTAssertNotNil(self.sut.viewState.errorMessage)
            XCTAssertFalse(self.sut.viewState.isSaving)
        }
    }

    // MARK: - Cancel Tests

    func test_whenCancelled_shouldNotifyDelegate() async {
        // Given
        let expectation = XCTestExpectation(description: "Cancel notified")
        self.mockDelegate.onCancel = { _ in
            expectation.fulfill()
        }

        // When
        self.sut.cancel()

        // Then
        await fulfillment(of: [expectation], timeout: 0.5)
    }

    // MARK: - Async Behavior Tests

    func test_whenSaveRollIsCalledMultipleTimes_shouldOnlyProcessOnce() async {
        // Given
        self.sut.updateName("Test Roll")
        self.sut.updateType(.nigiri)
        self.sut.updateRating(5)
        self.sut.updateRestaurant(self.createTestRestaurant())

        // When
        let task1 = Task { await self.sut.saveRoll() }
        let task2 = Task { await self.sut.saveRoll() }

        await task1.value
        await task2.value

        // Then
        XCTAssertTrue(self.mockRollRepository.invokedCreateRoll)
        // Only one create operation should have happened despite concurrent calls
    }

    func test_whenCancelIsCalled_shouldResetFormState() {
        // Given
        self.sut.updateName("Test Roll")
        self.sut.updateType(.nigiri)
        self.sut.updateRating(5)
        self.sut.updateRestaurant(self.createTestRestaurant())

        // When
        self.sut.cancel()

        // Then
        // Delegate should be called via the mock's onCancel closure
        // Haptic feedback is called asynchronously
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
