//
// FeedCardBuilder.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Foundation

@available(iOS 15.0, *)
enum FeedCardBuilder {
    static func createRollCards(
        from rolls: [Roll],
        chefCache: [ChefID: Chef],
        restaurantCache: [RestaurantID: Restaurant]
    ) -> [RollCardViewState] {
        rolls.map { roll in
            let chef = chefCache[roll.chefID]
            let restaurant = restaurantCache[roll.restaurantID]

            return RollCardViewState(
                id: roll.id.value.uuidString,
                chefName: chef?.displayName ?? "Unknown Chef",
                chefAvatarURL: chef?.avatarURL,
                restaurantName: restaurant?.name ?? "Unknown Restaurant",
                rollName: roll.name,
                rollType: roll.type.displayName,
                rating: roll.rating.value,
                description: roll.description,
                photoURL: roll.photoURL,
                timeAgo: self.formatTimeAgo(from: roll.createdAt),
                tags: roll.tags
            )
        }
    }

    private static func formatTimeAgo(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
