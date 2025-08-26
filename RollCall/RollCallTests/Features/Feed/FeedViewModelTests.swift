//
// FeedViewModelTests.swift
// RollCallTests
//
// Unit tests for FeedViewModel with >80% coverage
//

import Combine
@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class FeedViewModelTests: XCTestCase {
    // MARK: - Properties

    private var sut: FeedViewModel!
    private var mockRollRepository: MockRollRepository!
    private var mockChefRepository: MockChefRepository!
    private var mockRestaurantRepository: MockRestaurantRepository!
    private var mockHapticService: MockHapticFeedbackService!
    private var cancellables: Set<AnyCancellable>!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        self.mockRollRepository = MockRollRepository()
        self.mockChefRepository = MockChefRepository()
        self.mockRestaurantRepository = MockRestaurantRepository()
        self.mockHapticService = MockHapticFeedbackService()
        self.cancellables = []

        self.sut = FeedViewModel(
            rollRepository: self.mockRollRepository,
            chefRepository: self.mockChefRepository,
            restaurantRepository: self.mockRestaurantRepository,
            hapticService: self.mockHapticService
        )
    }

    override func tearDown() {
        self.cancellables = nil
        self.sut = nil
        self.mockRollRepository = nil
        self.mockChefRepository = nil
        self.mockRestaurantRepository = nil
        self.mockHapticService = nil

        super.tearDown()
    }

    // MARK: - Tests: Initial State

    func test_whenInitialized_shouldHaveInitialState() {
        XCTAssertEqual(self.sut.viewState, FeedViewState.initial)
        XCTAssertTrue(self.sut.viewState.isLoading)
        XCTAssertTrue(self.sut.viewState.rolls.isEmpty)
        XCTAssertNil(self.sut.viewState.error)
    }

    // MARK: - Tests: View Appeared

    func test_whenViewAppeared_shouldLoadInitialContent() async {
        // Given
        let mockRolls = createMockRolls(count: 5)
        self.mockRollRepository.stubbedFetchAllRollsResult = .success(mockRolls)
        self.mockChefRepository.stubbedFetchChefResult = createMockChef()
        self.mockRestaurantRepository.stubbedFetchRestaurantResult = createMockRestaurant()

        let expectation = XCTestExpectation(description: "View state updated")

        self.sut.$viewState
            .dropFirst() // Skip initial state
            .first { !$0.isLoading && !$0.rolls.isEmpty }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &self.cancellables)

        // When
        self.sut.onViewAppeared()

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)

        XCTAssertFalse(self.sut.viewState.isLoading)
        XCTAssertEqual(self.sut.viewState.rolls.count, 5)
        XCTAssertNil(self.sut.viewState.error)
        XCTAssertTrue(self.mockRollRepository.invokedFetchAllRolls)
    }

    func test_whenViewAppearedWithEmptyData_shouldShowEmptyState() async {
        // Given
        self.mockRollRepository.stubbedFetchAllRollsResult = .success([])

        let expectation = XCTestExpectation(description: "Empty state shown")

        self.sut.$viewState
            .dropFirst()
            .first { !$0.isLoading && $0.rolls.isEmpty && $0.emptyStateMessage != nil }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &self.cancellables)

        // When
        self.sut.onViewAppeared()

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)

        XCTAssertEqual(self.sut.viewState, FeedViewState.empty)
        XCTAssertNotNil(self.sut.viewState.emptyStateMessage)
    }

    func test_whenViewAppearedTwice_shouldNotReload() {
        // Given
        self.mockRollRepository.stubbedFetchAllRollsResult = .success([])

        // When
        self.sut.onViewAppeared()
        self.mockRollRepository.invokedFetchAllRollsCount = 0 // Reset
        self.sut.onViewAppeared()

        // Then
        XCTAssertEqual(self.mockRollRepository.invokedFetchAllRollsCount, 0)
    }

    // MARK: - Tests: Refresh

    func test_whenRefreshRequested_shouldReloadContent() async {
        // Given
        let mockRolls = createMockRolls(count: 3)
        self.mockRollRepository.stubbedFetchAllRollsResult = .success(mockRolls)
        self.mockChefRepository.stubbedFetchChefResult = createMockChef()
        self.mockRestaurantRepository.stubbedFetchRestaurantResult = createMockRestaurant()

        // First load
        self.sut.onViewAppeared()
        await Task.yield()

        let expectation = XCTestExpectation(description: "Refresh completed")

        self.sut.$viewState
            .dropFirst(2) // Skip loading and refreshing states
            .first { !$0.isRefreshing && !$0.isLoading }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &self.cancellables)

        // When
        self.sut.onRefreshRequested()

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertFalse(self.sut.viewState.isRefreshing)
        XCTAssertEqual(self.mockRollRepository.invokedFetchAllRollsCount, 2) // Initial + refresh
        XCTAssertTrue(self.mockHapticService.invokedNotification)
        XCTAssertEqual(self.mockHapticService.invokedNotificationType, .success)
    }

    // MARK: - Tests: Load More

    func test_whenLoadMoreRequested_shouldLoadNextPage() async {
        // Given
        let allRolls = createMockRolls(count: 25) // More than one page
        self.mockRollRepository.stubbedFetchAllRollsResult = .success(allRolls)
        self.mockChefRepository.stubbedFetchChefResult = createMockChef()
        self.mockRestaurantRepository.stubbedFetchRestaurantResult = createMockRestaurant()

        // Load first page
        self.sut.onViewAppeared()
        await Task.yield()

        let initialCount = self.sut.viewState.rolls.count
        XCTAssertEqual(initialCount, 20) // First page

        let expectation = XCTestExpectation(description: "More content loaded")

        self.sut.$viewState
            .dropFirst()
            .first { $0.rolls.count > initialCount }
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &self.cancellables)

        // When
        self.sut.onLoadMoreRequested()

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)

        XCTAssertEqual(self.sut.viewState.rolls.count, 25)
        XCTAssertFalse(self.sut.viewState.hasMoreContent)
    }

    func test_whenLoadMoreRequestedWhileLoading_shouldIgnore() async {
        // Given - Start loading
        self.mockRollRepository.stubbedFetchAllRollsResult = .success(createMockRolls(count: 30))
        self.mockChefRepository.stubbedFetchChefResult = createMockChef()
        self.mockRestaurantRepository.stubbedFetchRestaurantResult = createMockRestaurant()

        self.sut.onViewAppeared()
        // Don't wait for completion, immediately try to load more while still loading

        // When
        self.sut.onLoadMoreRequested()

        // Then - Should not trigger additional fetches
        await Task.yield()
        XCTAssertEqual(self.mockRollRepository.invokedFetchAllRollsCount, 1) // Only initial load
    }

    func test_whenLoadMoreRequestedWithNoMoreContent_shouldIgnore() async {
        // Given - Load all content (less than page size)
        let allRolls = createMockRolls(count: 10) // Less than page size of 20
        self.mockRollRepository.stubbedFetchAllRollsResult = .success(allRolls)
        self.mockChefRepository.stubbedFetchChefResult = createMockChef()
        self.mockRestaurantRepository.stubbedFetchRestaurantResult = createMockRestaurant()

        self.sut.onViewAppeared()
        await Task.yield()

        XCTAssertFalse(self.sut.viewState.hasMoreContent) // Verify no more content
        self.mockRollRepository.invokedFetchAllRollsCount = 0 // Reset counter

        // When
        self.sut.onLoadMoreRequested()

        // Then
        await Task.yield()
        XCTAssertEqual(self.mockRollRepository.invokedFetchAllRollsCount, 0) // No additional fetches
    }

    // MARK: - Tests: Navigation

    func test_whenRollTapped_shouldSendNavigationEvent() async {
        // Given
        let roll = createMockRoll()
        self.mockRollRepository.stubbedFetchAllRollsResult = .success([roll])
        self.mockChefRepository.stubbedFetchChefResult = createMockChef()
        self.mockRestaurantRepository.stubbedFetchRestaurantResult = createMockRestaurant()

        self.sut.onViewAppeared()
        await Task.yield()

        let expectation = XCTestExpectation(description: "Navigation event sent")
        var receivedRoll: Roll?

        self.sut.navigationEvent
            .sink { event in
                if case let .showRollDetail(roll) = event {
                    receivedRoll = roll
                    expectation.fulfill()
                }
            }
            .store(in: &self.cancellables)

        // When
        self.sut.onRollTapped(roll.id.value.uuidString)

        // Then
        await fulfillment(of: [expectation], timeout: 0.5)

        XCTAssertEqual(receivedRoll?.id, roll.id)
        XCTAssertTrue(self.mockHapticService.invokedImpact)
    }

    func test_whenRollTappedWithInvalidId_shouldNotNavigate() async {
        // Given
        let expectation = XCTestExpectation(description: "No navigation")
        expectation.isInverted = true

        self.sut.navigationEvent
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &self.cancellables)

        // When
        self.sut.onRollTapped("invalid-id")

        // Then
        await fulfillment(of: [expectation], timeout: 0.2)
        XCTAssertTrue(self.mockHapticService.invokedImpact) // Haptic still triggered
    }

    func test_whenCreateRollTapped_shouldSendNavigationEvent() async {
        // Given
        let expectation = XCTestExpectation(description: "Create navigation event sent")

        self.sut.navigationEvent
            .sink { event in
                if case .createNewRoll = event {
                    expectation.fulfill()
                }
            }
            .store(in: &self.cancellables)

        // When
        self.sut.onCreateRollTapped()

        // Then
        await fulfillment(of: [expectation], timeout: 0.5)

        XCTAssertTrue(self.mockHapticService.invokedImpact)
    }

    // MARK: - Tests: View State Mapping

    func test_whenCreatingRollCards_shouldMapCorrectly() async {
        // Given
        let chef = createMockChef()
        let restaurant = createMockRestaurant()
        let roll = Roll(
            id: RollID(),
            chefID: chef.id,
            restaurantID: restaurant.id,
            type: .nigiri,
            name: "Salmon Nigiri",
            description: "Fresh and buttery",
            rating: Rating(value: 5)!,
            photoURL: URL(string: "https://example.com/photo.jpg"),
            tags: ["salmon", "fresh"],
            createdAt: Date().addingTimeInterval(-3600),
            updatedAt: Date()
        )

        self.mockRollRepository.stubbedFetchAllRollsResult = .success([roll])
        self.mockChefRepository.stubbedFetchChefResult = chef
        self.mockRestaurantRepository.stubbedFetchRestaurantResult = restaurant

        // When
        self.sut.onViewAppeared()
        await Task.yield()

        // Then
        let rollCard = self.sut.viewState.rolls.first
        XCTAssertNotNil(rollCard)
        XCTAssertEqual(rollCard?.rollName, "Salmon Nigiri")
        XCTAssertEqual(rollCard?.chefName, chef.displayName)
        XCTAssertEqual(rollCard?.restaurantName, restaurant.name)
        XCTAssertEqual(rollCard?.rating, 5)
        XCTAssertEqual(rollCard?.rollType, "Nigiri")
        XCTAssertEqual(rollCard?.description, "Fresh and buttery")
        XCTAssertEqual(rollCard?.tags, ["salmon", "fresh"])
        XCTAssertNotNil(rollCard?.photoURL)
    }

    func test_whenCreatingRollCardsWithMissingData_shouldUseDefaults() async {
        // Given
        let roll = createMockRoll()
        self.mockRollRepository.stubbedFetchAllRollsResult = .success([roll])
        // Don't provide chef/restaurant data

        // When
        self.sut.onViewAppeared()
        await Task.yield()

        // Then
        let rollCard = self.sut.viewState.rolls.first
        XCTAssertEqual(rollCard?.chefName, "Unknown Chef")
        XCTAssertEqual(rollCard?.restaurantName, "Unknown Restaurant")
    }
}
