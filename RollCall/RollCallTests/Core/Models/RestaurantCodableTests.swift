//
// RestaurantCodableTests.swift
// RollCallTests
//
// Created for RollCall on 13/08/25.
//

@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class RestaurantCodableTests: XCTestCase {
    // MARK: - Codable Tests

    func test_restaurant_codable_shouldEncodeAndDecode() throws {
        let original = Restaurant(
            id: RestaurantID(),
            name: "Codable Sushi",
            address: Address(
                street: "999 Code St",
                city: "Binary City",
                state: "BC",
                postalCode: "10101",
                country: "Codeland"
            ),
            cuisine: .fusion,
            priceRange: .luxury,
            phoneNumber: "+1-234-567-8901",
            website: URL(string: "https://codable.sushi"),
            coordinates: Coordinates(latitude: 1.0, longitude: 0.0),
            rating: 5.0,
            photoURLs: [URL(string: "https://photo.url")!],
            isOmakaseOffered: true,
            createdAt: Date(),
            updatedAt: Date()
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(Restaurant.self, from: data)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.address, original.address)
        XCTAssertEqual(decoded.coordinates, original.coordinates)
        XCTAssertEqual(decoded.phoneNumber, original.phoneNumber)
        XCTAssertEqual(decoded.website, original.website)
        XCTAssertEqual(decoded.photoURLs, original.photoURLs)
        XCTAssertEqual(decoded.rating, original.rating)
        XCTAssertEqual(decoded.priceRange, original.priceRange)
        XCTAssertEqual(decoded.cuisine, original.cuisine)
        XCTAssertEqual(decoded.isOmakaseOffered, original.isOmakaseOffered)
    }

    func test_restaurant_codable_withNilValues_shouldEncodeAndDecode() throws {
        let original = Restaurant(
            id: RestaurantID(),
            name: "Minimal Codable",
            address: Address(
                street: "111 Min St",
                city: "Minimal",
                state: "MN",
                postalCode: "00001",
                country: "Minimal Land"
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

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(Restaurant.self, from: data)

        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.coordinates.latitude, 0.0)
        XCTAssertEqual(decoded.coordinates.longitude, 0.0)
        XCTAssertNil(decoded.phoneNumber)
        XCTAssertNil(decoded.website)
        XCTAssertTrue(decoded.photoURLs.isEmpty)
        XCTAssertEqual(decoded.rating, 1.0)
        XCTAssertEqual(decoded.priceRange, .budget)
        XCTAssertEqual(decoded.cuisine, .casual)
        XCTAssertFalse(decoded.isOmakaseOffered)
    }

    func test_address_codable_shouldEncodeAndDecode() throws {
        let original = Address(
            street: "Encode St",
            city: "Decode City",
            state: "DC",
            postalCode: "12345",
            country: "Codeland"
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Address.self, from: data)

        XCTAssertEqual(decoded, original)
    }

    func test_coordinates_codable_shouldEncodeAndDecode() throws {
        let original = Coordinates(latitude: 12.34, longitude: 56.78)

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Coordinates.self, from: data)

        XCTAssertEqual(decoded, original)
    }

    func test_priceRange_codable_shouldEncodeAndDecode() throws {
        for priceRange in PriceRange.allCases {
            let data = try JSONEncoder().encode(priceRange)
            let decoded = try JSONDecoder().decode(PriceRange.self, from: data)
            XCTAssertEqual(decoded, priceRange)
        }
    }

    // MARK: - Edge Cases

    func test_restaurant_withSpecialCharacters_shouldHandle() throws {
        let restaurant = Restaurant(
            id: RestaurantID(),
            name: "寿司屋 🍣 & Grill",
            address: Address(
                street: "東京都渋谷区 1-2-3",
                city: "東京",
                state: "東京都",
                postalCode: "150-0001",
                country: "日本"
            ),
            cuisine: .traditional,
            priceRange: .moderate,
            phoneNumber: nil,
            website: nil,
            coordinates: Coordinates(latitude: 35.6762, longitude: 139.6503),
            rating: 4.0,
            photoURLs: [],
            isOmakaseOffered: true,
            createdAt: Date(),
            updatedAt: Date()
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(restaurant)
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Restaurant.self, from: data)

        XCTAssertEqual(decoded.name, restaurant.name)
        XCTAssertEqual(decoded.address.city, "東京")
        XCTAssertEqual(decoded.cuisine, .traditional)
    }
}
