//
// RestaurantPickerViewModelTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class RestaurantPickerViewModelTests: XCTestCase {
    private var viewModel: RestaurantPickerViewModel!
    private var mockRestaurantRepository: TestRestaurantRepository!

    override func setUp() {
        super.setUp()
        self.mockRestaurantRepository = TestRestaurantRepository()
        self.viewModel = RestaurantPickerViewModel(restaurantRepository: self.mockRestaurantRepository)
    }

    override func tearDown() {
        self.viewModel = nil
        self.mockRestaurantRepository = nil
        super.tearDown()
    }

    // MARK: - Initial State Tests

    func test_whenInitialized_shouldHaveCorrectInitialState() {
        XCTAssertEqual(self.viewModel.viewState.restaurants.count, 0)
        XCTAssertFalse(self.viewModel.viewState.isLoading)
        XCTAssertNil(self.viewModel.viewState.error)
    }

    // MARK: - Load Restaurants Tests

    func test_whenLoadRestaurants_shouldSetLoadingState() async {
        let expectation = XCTestExpectation(description: "Loading state")

        // Given
        self.mockRestaurantRepository.shouldDelay = true

        // When
        Task { [weak self] in
            await self?.viewModel.loadRestaurants()
        }

        // Then - check loading state immediately
        await Task.yield()
        XCTAssertTrue(self.viewModel.viewState.isLoading)
        expectation.fulfill()

        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func test_whenLoadRestaurantsSucceeds_shouldUpdateViewState() async {
        // Given
        let (mockRestaurants, _) = MockRestaurantData.createMockRestaurants()
        self.mockRestaurantRepository.restaurants = mockRestaurants

        // When
        await self.viewModel.loadRestaurants()

        // Then
        XCTAssertEqual(self.viewModel.viewState.restaurants.count, mockRestaurants.count)
        XCTAssertFalse(self.viewModel.viewState.isLoading)
        XCTAssertNil(self.viewModel.viewState.error)
    }

    func test_whenLoadRestaurantsFails_shouldSetErrorState() async {
        // Given
        self.mockRestaurantRepository.shouldFail = true

        // When
        await self.viewModel.loadRestaurants()

        // Then
        XCTAssertEqual(self.viewModel.viewState.restaurants.count, 0)
        XCTAssertFalse(self.viewModel.viewState.isLoading)
        XCTAssertNotNil(self.viewModel.viewState.error)
    }

    // MARK: - Search Filter Tests

    func test_whenSearchTextChanges_shouldFilterRestaurants() async {
        // Given
        let (mockRestaurants, _) = MockRestaurantData.createMockRestaurants()
        self.mockRestaurantRepository.restaurants = mockRestaurants
        await self.viewModel.loadRestaurants()

        // When
        let filteredResults = self.viewModel.filteredRestaurants(searchText: "Sushi")

        // Then
        let expectedCount = mockRestaurants.filter { $0.name.localizedCaseInsensitiveContains("Sushi") }.count
        XCTAssertEqual(filteredResults.count, expectedCount)
    }

    func test_whenSearchTextIsEmpty_shouldReturnAllRestaurants() async {
        // Given
        let (mockRestaurants, _) = MockRestaurantData.createMockRestaurants()
        self.mockRestaurantRepository.restaurants = mockRestaurants
        await self.viewModel.loadRestaurants()

        // When
        let filteredResults = self.viewModel.filteredRestaurants(searchText: "")

        // Then
        XCTAssertEqual(filteredResults.count, mockRestaurants.count)
    }

    func test_whenSearchTextHasNoMatches_shouldReturnEmptyArray() async {
        // Given
        let (mockRestaurants, _) = MockRestaurantData.createMockRestaurants()
        self.mockRestaurantRepository.restaurants = mockRestaurants
        await self.viewModel.loadRestaurants()

        // When
        let filteredResults = self.viewModel.filteredRestaurants(searchText: "NonExistentRestaurant")

        // Then
        XCTAssertEqual(filteredResults.count, 0)
    }

    // MARK: - Edge Cases

    func test_whenSearchIsCaseInsensitive_shouldFindMatches() async {
        // Given
        let (mockRestaurants, _) = MockRestaurantData.createMockRestaurants()
        self.mockRestaurantRepository.restaurants = mockRestaurants
        await self.viewModel.loadRestaurants()

        // When
        let lowercaseResults = self.viewModel.filteredRestaurants(searchText: "sushi")
        let uppercaseResults = self.viewModel.filteredRestaurants(searchText: "SUSHI")

        // Then
        XCTAssertEqual(lowercaseResults.count, uppercaseResults.count)
        XCTAssertTrue(!lowercaseResults.isEmpty || !uppercaseResults.isEmpty)
    }
}

// MARK: - Test Repository

@available(iOS 15.0, *)
private class TestRestaurantRepository: RestaurantRepositoryProtocol {
    var restaurants: [Restaurant] = []
    var shouldFail = false
    var shouldDelay = false

    func fetchAllRestaurants() async throws -> [Restaurant] {
        if self.shouldDelay {
            try await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
        }

        if self.shouldFail {
            throw AppError.networkError
        }

        return self.restaurants
    }

    func fetchRestaurant(by id: RestaurantID) async throws -> Restaurant? {
        guard let restaurant = restaurants.first(where: { $0.id == id }) else {
            return nil
        }
        return restaurant
    }

    func createRestaurant(_ restaurant: Restaurant) async throws -> Restaurant {
        self.restaurants.append(restaurant)
        return restaurant
    }

    func updateRestaurant(_ restaurant: Restaurant) async throws -> Restaurant {
        if let index = restaurants.firstIndex(where: { $0.id == restaurant.id }) {
            self.restaurants[index] = restaurant
            return restaurant
        }
        throw AppError.notFound("Restaurant not found")
    }

    func searchRestaurants(query: String) async throws -> [Restaurant] {
        let lowercasedQuery = query.lowercased()
        return self.restaurants.filter { restaurant in
            restaurant.name.lowercased().contains(lowercasedQuery) ||
                restaurant.address.street.lowercased().contains(lowercasedQuery) ||
                restaurant.address.city.lowercased().contains(lowercasedQuery)
        }
    }
}
