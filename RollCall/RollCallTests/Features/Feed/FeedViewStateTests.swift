//
// FeedViewStateTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class FeedViewStateTests: XCTestCase {
    // MARK: - Tests: FeedViewState

    func test_whenInitializedWithDefaults_shouldHaveCorrectValues() {
        // When
        let state = FeedViewState()

        // Then
        XCTAssertTrue(state.rolls.isEmpty)
        XCTAssertFalse(state.isLoading)
        XCTAssertFalse(state.isRefreshing)
        XCTAssertNil(state.error)
        XCTAssertTrue(state.hasMoreContent)
        XCTAssertNil(state.emptyStateMessage)
    }

    func test_whenInitialState_shouldBeLoading() {
        // When
        let state = FeedViewState.initial

        // Then
        XCTAssertTrue(state.isLoading)
        XCTAssertTrue(state.rolls.isEmpty)
        XCTAssertFalse(state.isRefreshing)
        XCTAssertNil(state.error)
    }

    func test_whenEmptyState_shouldHaveMessage() {
        // When
        let state = FeedViewState.empty

        // Then
        XCTAssertTrue(state.rolls.isEmpty)
        XCTAssertFalse(state.isLoading)
        XCTAssertFalse(state.hasMoreContent)
        XCTAssertNotNil(state.emptyStateMessage)
        XCTAssertTrue(state.emptyStateMessage!.contains("No rolls yet"))
    }

    func test_whenEquatable_shouldCompareCorrectly() {
        // Given
        let rollCard1 = RollCardViewState(
            id: "1",
            chefName: "Chef 1",
            restaurantName: "Restaurant 1",
            rollName: "Roll 1",
            rollType: "Nigiri",
            rating: 5,
            timeAgo: "1 hour ago"
        )

        let rollCard2 = RollCardViewState(
            id: "2",
            chefName: "Chef 2",
            restaurantName: "Restaurant 2",
            rollName: "Roll 2",
            rollType: "Maki",
            rating: 4,
            timeAgo: "2 hours ago"
        )

        let state1 = FeedViewState(rolls: [rollCard1], isLoading: false)
        let state2 = FeedViewState(rolls: [rollCard1], isLoading: false)
        let state3 = FeedViewState(rolls: [rollCard2], isLoading: false)
        let state4 = FeedViewState(rolls: [rollCard1], isLoading: true)

        // Then
        XCTAssertEqual(state1, state2)
        XCTAssertNotEqual(state1, state3)
        XCTAssertNotEqual(state1, state4)
    }

    // MARK: - Tests: RollCardViewState

    func test_whenRollCardInitialized_shouldHaveCorrectValues() {
        // Given
        let id = UUID().uuidString
        let photoURL = URL(string: "https://example.com/photo.jpg")
        let avatarURL = URL(string: "https://example.com/avatar.jpg")
        let tags = ["fresh", "premium"]

        // When
        let card = RollCardViewState(
            id: id,
            chefName: "Kenji Tanaka",
            chefAvatarURL: avatarURL,
            restaurantName: "Sukiyabashi Jiro",
            rollName: "Otoro Nigiri",
            rollType: "Nigiri",
            rating: 5,
            description: "Melt-in-your-mouth fatty tuna",
            photoURL: photoURL,
            timeAgo: "2 hours ago",
            tags: tags
        )

        // Then
        XCTAssertEqual(card.id, id)
        XCTAssertEqual(card.chefName, "Kenji Tanaka")
        XCTAssertEqual(card.chefAvatarURL, avatarURL)
        XCTAssertEqual(card.restaurantName, "Sukiyabashi Jiro")
        XCTAssertEqual(card.rollName, "Otoro Nigiri")
        XCTAssertEqual(card.rollType, "Nigiri")
        XCTAssertEqual(card.rating, 5)
        XCTAssertEqual(card.description, "Melt-in-your-mouth fatty tuna")
        XCTAssertEqual(card.photoURL, photoURL)
        XCTAssertEqual(card.timeAgo, "2 hours ago")
        XCTAssertEqual(card.tags, tags)
    }

    func test_whenRollCardInitializedWithDefaults_shouldHaveNilOptionals() {
        // When
        let card = RollCardViewState(
            id: "1",
            chefName: "Chef",
            restaurantName: "Restaurant",
            rollName: "Roll",
            rollType: "Nigiri",
            rating: 4,
            timeAgo: "1 hour ago"
        )

        // Then
        XCTAssertNil(card.chefAvatarURL)
        XCTAssertNil(card.description)
        XCTAssertNil(card.photoURL)
        XCTAssertTrue(card.tags.isEmpty)
    }

    func test_whenRollCardEquatable_shouldCompareAllFields() {
        // Given
        let card1 = RollCardViewState(
            id: "1",
            chefName: "Chef",
            restaurantName: "Restaurant",
            rollName: "Roll",
            rollType: "Nigiri",
            rating: 5,
            timeAgo: "1 hour ago"
        )

        let card2 = RollCardViewState(
            id: "1",
            chefName: "Chef",
            restaurantName: "Restaurant",
            rollName: "Roll",
            rollType: "Nigiri",
            rating: 5,
            timeAgo: "1 hour ago"
        )

        let card3 = RollCardViewState(
            id: "2", // Different ID
            chefName: "Chef",
            restaurantName: "Restaurant",
            rollName: "Roll",
            rollType: "Nigiri",
            rating: 5,
            timeAgo: "1 hour ago"
        )

        let card4 = RollCardViewState(
            id: "1",
            chefName: "Different Chef", // Different chef name
            restaurantName: "Restaurant",
            rollName: "Roll",
            rollType: "Nigiri",
            rating: 5,
            timeAgo: "1 hour ago"
        )

        // Then
        XCTAssertEqual(card1, card2)
        XCTAssertNotEqual(card1, card3)
        XCTAssertNotEqual(card1, card4)
    }

    func test_whenRollCardIdentifiable_shouldUseId() {
        // Given
        let id = UUID().uuidString
        let card = RollCardViewState(
            id: id,
            chefName: "Chef",
            restaurantName: "Restaurant",
            rollName: "Roll",
            rollType: "Nigiri",
            rating: 4,
            timeAgo: "1 hour ago"
        )

        // Then
        XCTAssertEqual(card.id, id)
    }
}
