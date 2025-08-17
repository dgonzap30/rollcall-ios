//
// RestaurantCoreTests.swift
// RollCallTests
//
// Created for RollCall on 13/08/25.
//

@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class RestaurantCoreTests: XCTestCase {
    // MARK: - Restaurant Initialization Tests

    func test_init_withAllProperties_shouldCreateRestaurant() {
        let id = RestaurantID()
        let address = Address(
            street: "123 Main St",
            city: "Tokyo",
            state: "Tokyo",
            postalCode: "100-0001",
            country: "Japan"
        )
        let coordinates = Coordinates(
            latitude: 35.6762,
            longitude: 139.6503
        )
        let website = URL(string: "https://sushi.com")!
        let photoURLs = [
            URL(string: "https://sushi.com/photo1.jpg")!,
            URL(string: "https://sushi.com/photo2.jpg")!
        ]
        let createdAt = Date().addingTimeInterval(-86400)
        let updatedAt = Date()

        let restaurant = Restaurant(
            id: id,
            name: "Tokyo Sushi",
            address: address,
            cuisine: .traditional,
            priceRange: .expensive,
            phoneNumber: "+81-3-1234-5678",
            website: website,
            coordinates: coordinates,
            rating: 4.5,
            photoURLs: photoURLs,
            isOmakaseOffered: true,
            createdAt: createdAt,
            updatedAt: updatedAt
        )

        XCTAssertEqual(restaurant.id, id)
        XCTAssertEqual(restaurant.name, "Tokyo Sushi")
        XCTAssertEqual(restaurant.address, address)
        XCTAssertEqual(restaurant.coordinates, coordinates)
        XCTAssertEqual(restaurant.phoneNumber, "+81-3-1234-5678")
        XCTAssertEqual(restaurant.website, website)
        XCTAssertEqual(restaurant.photoURLs, photoURLs)
        XCTAssertEqual(restaurant.rating, 4.5)
        XCTAssertEqual(restaurant.priceRange, .expensive)
        XCTAssertEqual(restaurant.cuisine, .traditional)
        XCTAssertTrue(restaurant.isOmakaseOffered)
        XCTAssertEqual(restaurant.createdAt, createdAt)
        XCTAssertEqual(restaurant.updatedAt, updatedAt)
    }

    func test_init_withMinimalProperties_shouldCreateRestaurant() {
        let restaurant = Restaurant(
            id: RestaurantID(),
            name: "Minimal Sushi",
            address: Address(
                street: "456 Side St",
                city: "Kyoto",
                state: "Kyoto",
                postalCode: "600-0001",
                country: "Japan"
            ),
            cuisine: .casual,
            priceRange: .budget,
            phoneNumber: nil,
            website: nil,
            coordinates: Coordinates(latitude: 0.0, longitude: 0.0),
            rating: 1.0,
            photoURLs: [],
            isOmakaseOffered: false,
            createdAt: Date(),
            updatedAt: Date()
        )

        XCTAssertEqual(restaurant.name, "Minimal Sushi")
        XCTAssertEqual(restaurant.coordinates.latitude, 0.0)
        XCTAssertEqual(restaurant.coordinates.longitude, 0.0)
        XCTAssertNil(restaurant.phoneNumber)
        XCTAssertNil(restaurant.website)
        XCTAssertTrue(restaurant.photoURLs.isEmpty)
        XCTAssertEqual(restaurant.rating, 1.0)
        XCTAssertEqual(restaurant.priceRange, .budget)
        XCTAssertEqual(restaurant.cuisine, .casual)
        XCTAssertFalse(restaurant.isOmakaseOffered)
    }

    // MARK: - Address Tests

    func test_address_init_shouldCreateAddress() {
        let address = Address(
            street: "789 Test Ave",
            city: "Osaka",
            state: "Osaka",
            postalCode: "530-0001",
            country: "Japan"
        )

        XCTAssertEqual(address.street, "789 Test Ave")
        XCTAssertEqual(address.city, "Osaka")
        XCTAssertEqual(address.state, "Osaka")
        XCTAssertEqual(address.postalCode, "530-0001")
        XCTAssertEqual(address.country, "Japan")
    }

    // MARK: - Coordinates Tests

    func test_coordinates_init_shouldCreateCoordinates() {
        let coordinates = Coordinates(
            latitude: 34.6937,
            longitude: 135.5023
        )

        XCTAssertEqual(coordinates.latitude, 34.6937)
        XCTAssertEqual(coordinates.longitude, 135.5023)
    }

    func test_coordinates_validRange_shouldBeValid() {
        let validCoordinates = [
            Coordinates(latitude: 90, longitude: 180),
            Coordinates(latitude: -90, longitude: -180),
            Coordinates(latitude: 0, longitude: 0),
            Coordinates(latitude: 45.5231, longitude: -122.6765)
        ]

        for coordinate in validCoordinates {
            XCTAssertGreaterThanOrEqual(coordinate.latitude, -90)
            XCTAssertLessThanOrEqual(coordinate.latitude, 90)
            XCTAssertGreaterThanOrEqual(coordinate.longitude, -180)
            XCTAssertLessThanOrEqual(coordinate.longitude, 180)
        }
    }

    // MARK: - PriceRange Tests

    func test_priceRange_allCases_shouldExist() {
        let allCases: [PriceRange] = [.budget, .moderate, .expensive, .luxury]
        XCTAssertEqual(PriceRange.allCases.count, 4)
        XCTAssertEqual(PriceRange.allCases, allCases)
    }

    func test_priceRange_displaySymbol_shouldReturnCorrectString() {
        XCTAssertEqual(PriceRange.budget.displaySymbol, "$")
        XCTAssertEqual(PriceRange.moderate.displaySymbol, "$$")
        XCTAssertEqual(PriceRange.expensive.displaySymbol, "$$$")
        XCTAssertEqual(PriceRange.luxury.displaySymbol, "$$$$")
    }

    // MARK: - CuisineType Tests

    func test_cuisineType_allCases_shouldExist() {
        let allCases: [CuisineType] = [.traditional, .fusion, .kaiseki, .casual, .omakase]
        XCTAssertEqual(CuisineType.allCases.count, 5)
        XCTAssertEqual(CuisineType.allCases, allCases)
    }
}
