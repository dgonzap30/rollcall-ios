//
// MockRollData.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Foundation

@available(iOS 15.0, *)
enum MockRollData {
    static func createMockRolls(chefIds: [ChefID], restaurantIds: [RestaurantID]) -> [Roll] {
        guard chefIds.count >= 5, restaurantIds.count >= 4 else {
            return []
        }

        return self.createPremiumRolls(chefIds: chefIds, restaurantIds: restaurantIds) +
            self.createClassicRolls(chefIds: chefIds, restaurantIds: restaurantIds) +
            self.createSpecialtyRolls(chefIds: chefIds, restaurantIds: restaurantIds)
    }

    private static func createPremiumRolls(chefIds: [ChefID], restaurantIds: [RestaurantID]) -> [Roll] {
        [
            self.createOtoroNigiri(chefId: chefIds[0], restaurantId: restaurantIds[0]),
            self.createOmakaseExperience(chefId: chefIds[0], restaurantId: restaurantIds[0]),
            self.createUniNigiri(chefId: chefIds[3], restaurantId: restaurantIds[0])
        ]
    }

    private static func createOtoroNigiri(chefId: ChefID, restaurantId: RestaurantID) -> Roll {
        Roll(
            id: RollID(),
            chefID: chefId,
            restaurantID: restaurantId,
            type: .nigiri,
            name: "Otoro Nigiri",
            description: "Absolutely melt-in-your-mouth fatty tuna. The marbling was exquisite!",
            rating: Rating(value: 5)!,
            photoURL: nil,
            tags: ["otoro", "premium", "musttry"],
            createdAt: Date().addingTimeInterval(-3600),
            updatedAt: Date().addingTimeInterval(-3600)
        )
    }

    private static func createOmakaseExperience(chefId: ChefID, restaurantId: RestaurantID) -> Roll {
        Roll(
            id: RollID(),
            chefID: chefId,
            restaurantID: restaurantId,
            type: .omakase,
            name: "20-Course Omakase",
            description: "Life-changing experience. Each piece was perfectly seasoned " +
                "and the progression was masterful.",
            rating: Rating(value: 5)!,
            photoURL: nil,
            tags: ["omakase", "experience", "masterpiece"],
            createdAt: Date().addingTimeInterval(-259_200),
            updatedAt: Date().addingTimeInterval(-259_200)
        )
    }

    private static func createUniNigiri(chefId: ChefID, restaurantId: RestaurantID) -> Roll {
        Roll(
            id: RollID(),
            chefID: chefId,
            restaurantID: restaurantId,
            type: .nigiri,
            name: "Uni Nigiri",
            description: "Sweet and creamy sea urchin. Not for everyone but I loved it!",
            rating: Rating(value: 5)!,
            photoURL: nil,
            tags: ["uni", "seaurchin", "delicacy"],
            createdAt: Date().addingTimeInterval(-1_209_600),
            updatedAt: Date().addingTimeInterval(-1_209_600)
        )
    }

    private static func createClassicRolls(chefIds: [ChefID], restaurantIds: [RestaurantID]) -> [Roll] {
        [
            self.createSpicyTunaRoll(chefId: chefIds[2], restaurantId: restaurantIds[3]),
            self.createBluefinTunaSashimi(chefId: chefIds[3], restaurantId: restaurantIds[2]),
            self.createSalmonNigiri(chefId: chefIds[1], restaurantId: restaurantIds[2]),
            self.createCaliforniaRoll(chefId: chefIds[2], restaurantId: restaurantIds[3])
        ]
    }

    private static func createSpicyTunaRoll(chefId: ChefID, restaurantId: RestaurantID) -> Roll {
        Roll(
            id: RollID(),
            chefID: chefId,
            restaurantID: restaurantId,
            type: .maki,
            name: "Spicy Tuna Roll",
            description: "Classic spicy tuna with a nice kick. Good value for the price.",
            rating: Rating(value: 4)!,
            photoURL: nil,
            tags: ["spicy", "classic", "value"],
            createdAt: Date().addingTimeInterval(-14400),
            updatedAt: Date().addingTimeInterval(-14400)
        )
    }

    private static func createBluefinTunaSashimi(chefId: ChefID, restaurantId: RestaurantID) -> Roll {
        Roll(
            id: RollID(),
            chefID: chefId,
            restaurantID: restaurantId,
            type: .sashimi,
            name: "Bluefin Tuna Sashimi",
            description: "Fresh from Tsukiji market. The texture and flavor were incredible.",
            rating: Rating(value: 5)!,
            photoURL: nil,
            tags: ["bluefin", "sashimi", "fresh"],
            createdAt: Date().addingTimeInterval(-86400),
            updatedAt: Date().addingTimeInterval(-86400)
        )
    }

    private static func createSalmonNigiri(chefId: ChefID, restaurantId: RestaurantID) -> Roll {
        Roll(
            id: RollID(),
            chefID: chefId,
            restaurantID: restaurantId,
            type: .nigiri,
            name: "Salmon Nigiri",
            description: "Buttery smooth salmon. Simple but executed perfectly.",
            rating: Rating(value: 4)!,
            photoURL: nil,
            tags: ["salmon", "classic"],
            createdAt: Date().addingTimeInterval(-345_600),
            updatedAt: Date().addingTimeInterval(-345_600)
        )
    }

    private static func createCaliforniaRoll(chefId: ChefID, restaurantId: RestaurantID) -> Roll {
        Roll(
            id: RollID(),
            chefID: chefId,
            restaurantID: restaurantId,
            type: .uramaki,
            name: "California Roll",
            description: "Not authentic but tasty. Good introduction for sushi beginners.",
            rating: Rating(value: 3)!,
            photoURL: nil,
            tags: ["california", "beginner"],
            createdAt: Date().addingTimeInterval(-604_800),
            updatedAt: Date().addingTimeInterval(-604_800)
        )
    }

    private static func createSpecialtyRolls(chefIds: [ChefID], restaurantIds: [RestaurantID]) -> [Roll] {
        [
            Roll(
                id: RollID(),
                chefID: chefIds[1],
                restaurantID: restaurantIds[1],
                type: .uramaki,
                name: "Black Cod Roll",
                description: "Nobu's signature miso black cod wrapped in cucumber. " +
                    "Perfect balance of sweet and savory.",
                rating: Rating(value: 5)!,
                photoURL: nil,
                tags: ["signature", "blackcod", "fusion"],
                createdAt: Date().addingTimeInterval(-7200),
                updatedAt: Date().addingTimeInterval(-7200)
            ),
            Roll(
                id: RollID(),
                chefID: chefIds[4],
                restaurantID: restaurantIds[1],
                type: .temaki,
                name: "Lobster Hand Roll",
                description: "Generous portion of lobster with avocado and spicy mayo. A bit messy but worth it!",
                rating: Rating(value: 4)!,
                photoURL: nil,
                tags: ["lobster", "handroll", "fusion"],
                createdAt: Date().addingTimeInterval(-172_800),
                updatedAt: Date().addingTimeInterval(-172_800)
            ),
            Roll(
                id: RollID(),
                chefID: chefIds[4],
                restaurantID: restaurantIds[1],
                type: .maki,
                name: "Yellowtail Jalapeño Roll",
                description: "Nice heat from the jalapeño balanced with the fatty yellowtail.",
                rating: Rating(value: 4)!,
                photoURL: nil,
                tags: ["yellowtail", "spicy", "fusion"],
                createdAt: Date().addingTimeInterval(-2_419_200),
                updatedAt: Date().addingTimeInterval(-2_419_200)
            )
        ]
    }

    static func generateAdditionalRoll(
        index: Int,
        chefs: [Chef],
        restaurants: [Restaurant],
        baseDate: Date
    ) -> Roll {
        let randomChef = chefs.randomElement()!
        let randomRestaurant = restaurants.randomElement()!
        let randomType = RollType.allCases.randomElement()!
        let randomRating = Int.random(in: 3...5)

        return Roll(
            id: RollID(),
            chefID: randomChef.id,
            restaurantID: randomRestaurant.id,
            type: randomType,
            name: "Test Roll #\(index + 1)",
            description: "Auto-generated roll for testing pagination and infinite scroll.",
            rating: Rating(value: randomRating)!,
            photoURL: nil,
            tags: ["test", "generated"],
            createdAt: baseDate.addingTimeInterval(Double(-index * 3600)),
            updatedAt: baseDate.addingTimeInterval(Double(-index * 3600))
        )
    }
}
