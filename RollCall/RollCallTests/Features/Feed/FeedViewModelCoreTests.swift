//
// FeedViewModelCoreTests.swift
// RollCallTests
//
// Created for RollCall on 13/08/25.
//

@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class FeedViewModelCoreTests: XCTestCase {
    // MARK: - Properties

    private var viewModel: FeedViewModel!
    private var mockRollRepository: MockRollRepository!
    private var mockChefRepository: MockChefRepository!
    private var mockRestaurantRepository: MockRestaurantRepository!
    private var mockHapticService: MockHapticFeedbackService!
    private var mockContainer: MockContainer!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        self.mockRollRepository = MockRollRepository()
        self.mockChefRepository = MockChefRepository()
        self.mockRestaurantRepository = MockRestaurantRepository()
        self.mockHapticService = MockHapticFeedbackService()

        self.mockContainer = MockContainer()
        self.mockContainer.register(RollRepositoryProtocol.self, instance: self.mockRollRepository)
        self.mockContainer.register(ChefRepositoryProtocol.self, instance: self.mockChefRepository)
        self.mockContainer.register(RestaurantRepositoryProtocol.self, instance: self.mockRestaurantRepository)
        self.mockContainer.register(HapticFeedbackServicing.self, instance: self.mockHapticService)

        self.viewModel = FeedViewModel(
            rollRepository: self.mockRollRepository,
            chefRepository: self.mockChefRepository,
            restaurantRepository: self.mockRestaurantRepository,
            hapticService: self.mockHapticService
        )
    }

    override func tearDown() {
        self.viewModel = nil
        self.mockRollRepository = nil
        self.mockChefRepository = nil
        self.mockRestaurantRepository = nil
        self.mockHapticService = nil
        self.mockContainer = nil
        super.tearDown()
    }

    // MARK: - Tests: Initial State

    func test_init_shouldSetInitialState() {
        XCTAssertEqual(self.viewModel.viewState.rolls.count, 0)
        XCTAssertFalse(self.viewModel.viewState.isLoading)
        XCTAssertFalse(self.viewModel.viewState.isRefreshing)
        XCTAssertNil(self.viewModel.viewState.error)
        XCTAssertTrue(self.viewModel.viewState.hasMoreContent)
    }

    // MARK: - Tests: View Appeared

    func test_onViewAppeared_withNoRolls_shouldShowEmptyState() async {
        // Given
        self.mockRollRepository.mockRolls = []

        // When
        await self.viewModel.onViewAppeared()

        // Then
        XCTAssertEqual(self.viewModel.viewState, .empty)
    }

    func test_onViewAppeared_withRolls_shouldLoadSuccessfully() async {
        // Given
        let testData = FeedTestUtilities.createTestData()
        let rolls = testData.rolls
        let restaurants = testData.restaurants
        self.mockRollRepository.mockRolls = rolls
        // MockChefRepository only stores a single chef, not a collection
        self.mockRestaurantRepository.mockRestaurants = restaurants

        // When
        await self.viewModel.onViewAppeared()

        // Then
        XCTAssertEqual(self.viewModel.viewState.rolls.count, min(rolls.count, 20)) // Page size
        XCTAssertFalse(self.viewModel.viewState.isLoading)
        XCTAssertNil(self.viewModel.viewState.error)
    }

    func test_onViewAppeared_withRepositoryError_shouldShowError() async {
        // Given
        self.mockRollRepository.shouldThrowError = true

        // When
        await self.viewModel.onViewAppeared()

        // Then
        XCTAssertNotNil(self.viewModel.viewState.error)
        XCTAssertFalse(self.viewModel.viewState.isLoading)
        XCTAssertEqual(self.viewModel.viewState.rolls.count, 0)
    }

    func test_onViewAppeared_shouldSetLoadingDuringFetch() async {
        // Given
        let testData = FeedTestUtilities.createTestData()
        let rolls = testData.rolls
        let restaurants = testData.restaurants
        self.mockRollRepository.mockRolls = rolls
        // MockChefRepository only stores a single chef, not a collection
        self.mockRestaurantRepository.mockRestaurants = restaurants

        // When
        Task {
            await self.viewModel.onViewAppeared()
        }

        // Check loading state immediately
        await Task.yield()
        XCTAssertTrue(self.viewModel.viewState.isLoading)
    }

    func test_onViewAppeared_withLargeDataSet_shouldHandlePaging() async {
        // Given
        let testData = FeedTestUtilities.createLargeTestData(rollCount: 100)
        let largeRollSet = testData.rolls
        let chefs = testData.chefs
        let restaurants = testData.restaurants
        self.mockRollRepository.mockRolls = largeRollSet
        // MockChefRepository only stores a single chef
        self.mockRestaurantRepository.mockRestaurants = restaurants

        // When
        await self.viewModel.onViewAppeared()

        // Then
        XCTAssertEqual(self.viewModel.viewState.rolls.count, 20) // First page
        XCTAssertTrue(self.viewModel.viewState.hasMoreContent)
        XCTAssertFalse(self.viewModel.viewState.isLoading)
    }

    // MARK: - Tests: Navigation

    func test_navigationEvents_shouldBePublished() async {
        // Given
        let expectation = XCTestExpectation(description: "Navigation event published")
        let cancellable = self.viewModel.navigationEvent.sink { event in
            if case .showRollDetail = event {
                expectation.fulfill()
            }
        }

        // When
        let rollCard = FeedTestUtilities.createSampleRollCard()
        self.viewModel.onRollTapped(rollCard.id)

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        cancellable.cancel()
    }

    // MARK: - Tests: View State Mapping

    func test_viewStateMapping_shouldMapCorrectly() async {
        // Given
        let testData = FeedTestUtilities.createTestData()
        let rolls = testData.rolls
        let restaurants = testData.restaurants
        self.mockRollRepository.mockRolls = rolls
        // MockChefRepository only stores a single chef, not a collection
        self.mockRestaurantRepository.mockRestaurants = restaurants

        // When
        await self.viewModel.onViewAppeared()

        // Then
        let rollCards = self.viewModel.viewState.rolls
        XCTAssertEqual(rollCards.count, rolls.count)

        for (index, rollCard) in rollCards.enumerated() {
            let originalRoll = rolls[index]
            XCTAssertEqual(rollCard.id, originalRoll.id.value.uuidString)
            XCTAssertEqual(rollCard.rollName, originalRoll.name)
            XCTAssertEqual(rollCard.description, originalRoll.description)
            XCTAssertEqual(rollCard.rating, originalRoll.rating.value)
        }
    }
}
