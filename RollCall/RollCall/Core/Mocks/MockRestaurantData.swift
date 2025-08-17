//
// MockRestaurantData.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Foundation

@available(iOS 15.0, *)
enum MockRestaurantData {
    static func createMockRestaurants() -> (restaurants: [Restaurant], restaurantIds: [RestaurantID]) {
        let restaurantIds = self.generateRestaurantIds()
        let restaurants = [
            createSukiyabashiJiro(id: restaurantIds[0]),
            createNobuTokyo(id: restaurantIds[1]),
            createBlueRibbonSushi(id: restaurantIds[2]),
            createKaisekiMizuno(id: restaurantIds[3])
        ]

        return (restaurants: restaurants, restaurantIds: restaurantIds)
    }

    private static func generateRestaurantIds() -> [RestaurantID] {
        [RestaurantID(), RestaurantID(), RestaurantID(), RestaurantID()]
    }

    private static func createSukiyabashiJiro(id: RestaurantID) -> Restaurant {
        Restaurant(
            id: id,
            name: "Sukiyabashi Jiro",
            address: Address(
                street: "4-2-15 Ginza",
                city: "Chuo",
                state: "Tokyo",
                postalCode: "104-0061",
                country: "Japan"
            ),
            cuisine: .traditional,
            priceRange: .luxury,
            phoneNumber: "+81-3-3535-3600",
            website: nil,
            coordinates: Coordinates(latitude: 35.6762, longitude: 139.7653),
            rating: 4.8,
            photoURLs: [],
            isOmakaseOffered: true,
            createdAt: Date().addingTimeInterval(-1000 * 24 * 60 * 60),
            updatedAt: Date().addingTimeInterval(-24 * 60 * 60)
        )
    }

    private static func createNobuTokyo(id: RestaurantID) -> Restaurant {
        Restaurant(
            id: id,
            name: "Nobu Tokyo",
            address: Address(
                street: "4-1-28 Toranomon",
                city: "Minato",
                state: "Tokyo",
                postalCode: "105-0001",
                country: "Japan"
            ),
            cuisine: .fusion,
            priceRange: .luxury,
            phoneNumber: "+81-3-5733-0070",
            website: URL(string: "https://nobu-tokyo.com"),
            coordinates: Coordinates(latitude: 35.6695, longitude: 139.7514),
            rating: 4.6,
            photoURLs: [],
            isOmakaseOffered: true,
            createdAt: Date().addingTimeInterval(-800 * 24 * 60 * 60),
            updatedAt: Date().addingTimeInterval(-12 * 60 * 60)
        )
    }

    private static func createBlueRibbonSushi(id: RestaurantID) -> Restaurant {
        Restaurant(
            id: id,
            name: "Blue Ribbon Sushi",
            address: Address(
                street: "119 Sullivan St",
                city: "New York",
                state: "NY",
                postalCode: "10012",
                country: "USA"
            ),
            cuisine: .casual,
            priceRange: .moderate,
            phoneNumber: "+1-212-343-0404",
            website: URL(string: "https://blueribbonrestaurants.com"),
            coordinates: Coordinates(latitude: 40.7259, longitude: -74.0011),
            rating: 4.3,
            photoURLs: [],
            isOmakaseOffered: false,
            createdAt: Date().addingTimeInterval(-600 * 24 * 60 * 60),
            updatedAt: Date().addingTimeInterval(-48 * 60 * 60)
        )
    }

    private static func createKaisekiMizuno(id: RestaurantID) -> Restaurant {
        Restaurant(
            id: id,
            name: "Kaiseki Mizuno",
            address: Address(
                street: "2-3-7 Nihonbashi",
                city: "Chuo",
                state: "Tokyo",
                postalCode: "103-0027",
                country: "Japan"
            ),
            cuisine: .kaiseki,
            priceRange: .luxury,
            phoneNumber: "+81-3-3271-3436",
            website: nil,
            coordinates: Coordinates(latitude: 35.6795, longitude: 139.7731),
            rating: 4.9,
            photoURLs: [],
            isOmakaseOffered: true,
            createdAt: Date().addingTimeInterval(-1200 * 24 * 60 * 60),
            updatedAt: Date().addingTimeInterval(-6 * 60 * 60)
        )
    }
}
