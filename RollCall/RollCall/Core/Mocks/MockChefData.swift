//
// MockChefData.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Foundation

@available(iOS 15.0, *)
enum MockChefData {
    static func createMockChefs() -> (chefs: [Chef], chefIds: [ChefID]) {
        let chefIds = self.generateChefIds()
        let chefs = [
            createSushiExpertChef(id: chefIds[0]),
            createSakuraLoverChef(id: chefIds[1]),
            createRollingWaveChef(id: chefIds[2]),
            createWasabiWizChef(id: chefIds[3]),
            createTempuraTalesChef(id: chefIds[4])
        ]

        return (chefs: chefs, chefIds: chefIds)
    }

    private static func generateChefIds() -> [ChefID] {
        [ChefID(), ChefID(), ChefID(), ChefID(), ChefID()]
    }

    private static func createSushiExpertChef(id: ChefID) -> Chef {
        Chef(
            id: id,
            username: "sushimaster",
            displayName: "Kenji Tanaka",
            email: "kenji@example.com",
            bio: "Sushi enthusiast exploring Tokyo's hidden gems",
            avatarURL: nil,
            favoriteRollType: .nigiri,
            rollCount: 156,
            joinedAt: Date().addingTimeInterval(-365 * 24 * 60 * 60),
            lastActiveAt: Date().addingTimeInterval(-3600)
        )
    }

    private static func createSakuraLoverChef(id: ChefID) -> Chef {
        Chef(
            id: id,
            username: "sakuralover",
            displayName: "Yuki Sato",
            email: "yuki@example.com",
            bio: "Omakase adventures and seasonal delights",
            avatarURL: nil,
            favoriteRollType: .omakase,
            rollCount: 89,
            joinedAt: Date().addingTimeInterval(-180 * 24 * 60 * 60),
            lastActiveAt: Date().addingTimeInterval(-7200)
        )
    }

    private static func createRollingWaveChef(id: ChefID) -> Chef {
        Chef(
            id: id,
            username: "rollingwave",
            displayName: "Marina Chen",
            email: "marina@example.com",
            bio: "California roll innovator",
            avatarURL: nil,
            favoriteRollType: .uramaki,
            rollCount: 234,
            joinedAt: Date().addingTimeInterval(-730 * 24 * 60 * 60),
            lastActiveAt: Date().addingTimeInterval(-86400)
        )
    }

    private static func createWasabiWizChef(id: ChefID) -> Chef {
        Chef(
            id: id,
            username: "wasabiwiz",
            displayName: "Hiroshi Nakamura",
            email: "hiroshi@example.com",
            bio: "Traditional sushi purist",
            avatarURL: nil,
            favoriteRollType: .sashimi,
            rollCount: 312,
            joinedAt: Date().addingTimeInterval(-500 * 24 * 60 * 60),
            lastActiveAt: Date().addingTimeInterval(-10800)
        )
    }

    private static func createTempuraTalesChef(id: ChefID) -> Chef {
        Chef(
            id: id,
            username: "tempuratales",
            displayName: "Emma Rodriguez",
            email: "emma@example.com",
            bio: "Fusion sushi explorer",
            avatarURL: nil,
            favoriteRollType: .maki,
            rollCount: 67,
            joinedAt: Date().addingTimeInterval(-90 * 24 * 60 * 60),
            lastActiveAt: Date()
        )
    }
}
