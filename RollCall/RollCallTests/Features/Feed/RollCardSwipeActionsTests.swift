//
// RollCardSwipeActionsTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

@testable import RollCall
import SwiftUI
import XCTest

@available(iOS 15.0, *)
final class RollCardSwipeActionsTests: XCTestCase {
    private var testRoll: Roll!

    override func setUp() {
        super.setUp()
        self.testRoll = self.createTestRoll()
    }

    override func tearDown() {
        self.testRoll = nil
        super.tearDown()
    }

    // MARK: - Modifier Creation Tests

    func test_whenModifierCreated_shouldHaveCorrectInitialState() {
        // Given
        var editCalled = false
        var deleteCalled = false

        // When
        let modifier = RollCardSwipeActionsModifier(
            roll: testRoll,
            onEdit: { _ in editCalled = true },
            onDelete: { _ in deleteCalled = true }
        )

        // Then
        XCTAssertNotNil(modifier)
        XCTAssertFalse(editCalled)
        XCTAssertFalse(deleteCalled)
    }

    // MARK: - Action Callback Tests

    func test_whenOnEditCalled_shouldPassCorrectRoll() {
        // Given
        var receivedRoll: Roll?
        let modifier = RollCardSwipeActionsModifier(
            roll: testRoll,
            onEdit: { roll in
                receivedRoll = roll
            },
            onDelete: { _ in }
        )

        // When
        modifier.onEdit(self.testRoll)

        // Then
        XCTAssertEqual(receivedRoll?.id, self.testRoll.id)
        XCTAssertEqual(receivedRoll?.name, self.testRoll.name)
    }

    func test_whenOnDeleteCalled_shouldPassCorrectRoll() {
        // Given
        var receivedRoll: Roll?
        let modifier = RollCardSwipeActionsModifier(
            roll: testRoll,
            onEdit: { _ in },
            onDelete: { roll in
                receivedRoll = roll
            }
        )

        // When
        modifier.onDelete(self.testRoll)

        // Then
        XCTAssertEqual(receivedRoll?.id, self.testRoll.id)
        XCTAssertEqual(receivedRoll?.name, self.testRoll.name)
    }

    // MARK: - Multiple Actions Tests

    func test_whenMultipleActionsTriggered_shouldCallEachIndependently() {
        // Given
        var editCount = 0
        var deleteCount = 0

        let modifier = RollCardSwipeActionsModifier(
            roll: testRoll,
            onEdit: { _ in editCount += 1 },
            onDelete: { _ in deleteCount += 1 }
        )

        // When
        modifier.onEdit(self.testRoll)
        modifier.onDelete(self.testRoll)
        modifier.onEdit(self.testRoll)

        // Then
        XCTAssertEqual(editCount, 2)
        XCTAssertEqual(deleteCount, 1)
    }

    // MARK: - Helper Methods

    private func createTestRoll() -> Roll {
        Roll(
            id: RollID(),
            chefID: ChefID(),
            restaurantID: RestaurantID(),
            type: .maki,
            name: "Test Roll",
            description: "Test description",
            rating: Rating(value: 4)!, // Safe force unwrap - value is valid
            photoURL: nil,
            tags: ["test", "sushi"],
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}
