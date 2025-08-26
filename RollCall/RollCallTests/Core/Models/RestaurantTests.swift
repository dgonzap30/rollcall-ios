//
// RestaurantTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 22/07/25.
//

@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class RestaurantTests: XCTestCase {
    // MARK: - Initialization Tests

    func test_init_withAllProperties_createsRestaurant() {
        let id = RestaurantID()
        let address = Address(
            street: "123 Sushi St",
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
            priceRange: .luxury,
            phoneNumber: "+81 3-1234-5678",
            website: website,
            coordinates: coordinates,
            rating: 4.8,
            photoURLs: photoURLs,
            isOmakaseOffered: true,
            createdAt: createdAt,
            updatedAt: updatedAt
        )

        XCTAssertEqual(restaurant.id, id)
        XCTAssertEqual(restaurant.name, "Tokyo Sushi")
        XCTAssertEqual(restaurant.address, address)
        XCTAssertEqual(restaurant.cuisine, .traditional)
        XCTAssertEqual(restaurant.priceRange, .luxury)
        XCTAssertEqual(restaurant.phoneNumber, "+81 3-1234-5678")
        XCTAssertEqual(restaurant.website, website)
        XCTAssertEqual(restaurant.coordinates, coordinates)
        XCTAssertEqual(restaurant.rating, 4.8)
        XCTAssertEqual(restaurant.photoURLs, photoURLs)
        XCTAssertTrue(restaurant.isOmakaseOffered)
        XCTAssertEqual(restaurant.createdAt, createdAt)
        XCTAssertEqual(restaurant.updatedAt, updatedAt)
    }

    func test_init_withOptionalNilValues_createsRestaurant() {
        let restaurant = Restaurant(
            id: RestaurantID(),
            name: "Minimal Sushi",
            address: Address(
                street: "Unknown",
                city: "Unknown",
                state: "Unknown",
                postalCode: "00000",
                country: "Unknown"
            ),
            cuisine: .casual,
            priceRange: .budget,
            phoneNumber: nil,
            website: nil,
            coordinates: Coordinates(latitude: 0.0, longitude: 0.0),
            rating: 0.0,
            photoURLs: [],
            isOmakaseOffered: false,
            createdAt: Date(),
            updatedAt: Date()
        )

        XCTAssertNil(restaurant.phoneNumber)
        XCTAssertNil(restaurant.website)
        XCTAssertTrue(restaurant.photoURLs.isEmpty)
        XCTAssertEqual(restaurant.rating, 0.0)
    }

    // MARK: - RestaurantID Tests

    func test_restaurantID_uniqueness() {
        let id1 = RestaurantID()
        let id2 = RestaurantID()

        XCTAssertNotEqual(id1.value, id2.value)
        XCTAssertNotEqual(id1, id2)
    }

    func test_restaurantID_initWithValue() {
        let uuid = UUID()
        let id = RestaurantID(value: uuid)

        XCTAssertEqual(id.value, uuid)
    }

    // MARK: - Address Tests

    func test_address_equatable() {
        let address1 = Address(
            street: "123 Main St",
            city: "New York",
            state: "NY",
            postalCode: "10001",
            country: "USA"
        )

        let address2 = Address(
            street: "123 Main St",
            city: "New York",
            state: "NY",
            postalCode: "10001",
            country: "USA"
        )

        let address3 = Address(
            street: "456 Broadway",
            city: "New York",
            state: "NY",
            postalCode: "10002",
            country: "USA"
        )

        XCTAssertEqual(address1, address2)
        XCTAssertNotEqual(address1, address3)
    }

    // MARK: - Coordinates Tests

    func test_coordinates_validRange() {
        let validCoordinates = Coordinates(
            latitude: 40.7128,
            longitude: -74.0060
        )

        XCTAssertEqual(validCoordinates.latitude, 40.7128)
        XCTAssertEqual(validCoordinates.longitude, -74.0060)
    }

    func test_coordinates_equatable() {
        let coord1 = Coordinates(latitude: 35.6762, longitude: 139.6503)
        let coord2 = Coordinates(latitude: 35.6762, longitude: 139.6503)
        let coord3 = Coordinates(latitude: 40.7128, longitude: -74.0060)

        XCTAssertEqual(coord1, coord2)
        XCTAssertNotEqual(coord1, coord3)
    }

    // MARK: - PriceRange Tests

    func test_priceRange_allCases() {
        let allCases = PriceRange.allCases

        XCTAssertEqual(allCases.count, 4)
        XCTAssertTrue(allCases.contains(.budget))
        XCTAssertTrue(allCases.contains(.moderate))
        XCTAssertTrue(allCases.contains(.expensive))
        XCTAssertTrue(allCases.contains(.luxury))
    }

    func test_priceRange_displaySymbol() {
        XCTAssertEqual(PriceRange.budget.displaySymbol, "$")
        XCTAssertEqual(PriceRange.moderate.displaySymbol, "$$")
        XCTAssertEqual(PriceRange.expensive.displaySymbol, "$$$")
        XCTAssertEqual(PriceRange.luxury.displaySymbol, "$$$$")
    }

    // MARK: - CuisineType Tests

    func test_cuisineType_allCases() {
        let allCases = CuisineType.allCases

        XCTAssertEqual(allCases.count, 5)
        XCTAssertTrue(allCases.contains(.traditional))
        XCTAssertTrue(allCases.contains(.fusion))
        XCTAssertTrue(allCases.contains(.kaiseki))
        XCTAssertTrue(allCases.contains(.casual))
        XCTAssertTrue(allCases.contains(.omakase))
    }

    func test_cuisineType_rawValues() {
        XCTAssertEqual(CuisineType.traditional.rawValue, "Traditional")
        XCTAssertEqual(CuisineType.fusion.rawValue, "Fusion")
        XCTAssertEqual(CuisineType.kaiseki.rawValue, "Kaiseki")
        XCTAssertEqual(CuisineType.casual.rawValue, "Casual")
        XCTAssertEqual(CuisineType.omakase.rawValue, "Omakase")
    }
}
