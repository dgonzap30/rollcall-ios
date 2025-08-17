//
// FeedCoordinatorTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Combine
@testable import RollCall
import SwiftUI
import UIKit
import XCTest

@available(iOS 15.0, *)
final class FeedCoordinatorTests: XCTestCase {
    // MARK: - Properties

    private var sut: FeedCoordinator!
    private var navigationController: UINavigationController!
    private var mockDependencies: MockFeedDependencies!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        self.navigationController = UINavigationController()
        self.mockDependencies = MockFeedDependencies()

        self.sut = FeedCoordinator(
            navigationController: self.navigationController,
            dependencies: self.mockDependencies
        )
    }

    override func tearDown() {
        self.sut = nil
        self.navigationController = nil
        self.mockDependencies = nil

        super.tearDown()
    }

    // MARK: - Tests

    @MainActor
    func test_whenStartCalled_shouldReturnHostingController() {
        // When
        let viewController = self.sut.start()

        // Then
        XCTAssertTrue(viewController is UIHostingController<FeedView>)
        XCTAssertEqual(viewController.title, "Feed")
    }

    @MainActor
    func test_whenStartCalled_shouldConfigureNavigationBar() {
        // When
        let viewController = self.sut.start()

        // Then
        XCTAssertNotNil(viewController.navigationItem.standardAppearance)
        XCTAssertNotNil(viewController.navigationItem.scrollEdgeAppearance)
        XCTAssertNotNil(viewController.navigationItem.compactAppearance)

        // Check create button
        let rightBarButton = viewController.navigationItem.rightBarButtonItem
        XCTAssertNotNil(rightBarButton)
        XCTAssertEqual(rightBarButton?.image, UIImage(systemName: "plus.circle.fill"))
    }

    @MainActor
    func test_whenNavigationBarCreateButtonTapped_shouldShowCreateRoll() {
        // Given
        let viewController = self.sut.start()
        self.navigationController.viewControllers = [viewController]

        let createButton = viewController.navigationItem.rightBarButtonItem
        XCTAssertNotNil(createButton)

        // When
        _ = createButton?.target?.perform(createButton!.action, with: createButton)

        // Wait for presentation
        let expectation = XCTestExpectation(description: "Modal presented")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)

        // Then
        XCTAssertNotNil(self.navigationController.presentedViewController)
        XCTAssertTrue(self.navigationController.presentedViewController is UINavigationController)
    }

    @MainActor
    func test_whenShowRollDetailCalled_shouldPushViewController() {
        // Given
        let viewController = self.sut.start()
        self.navigationController.viewControllers = [viewController]

        let roll = Roll(
            id: RollID(),
            chefID: ChefID(),
            restaurantID: RestaurantID(),
            type: .nigiri,
            name: "Test Roll",
            description: nil,
            rating: Rating(value: 4)!,
            photoURL: nil,
            tags: [],
            createdAt: Date(),
            updatedAt: Date()
        )

        // When
        // Simulate navigation event by calling private method through reflection
        // In a real app, we'd test this through the ViewModel's navigation event
        let mirror = Mirror(reflecting: sut!)
        if let handleMethod = mirror.descendant("handle") as? (FeedNavigationEvent) -> Void {
            handleMethod(.showRollDetail(roll))
        }

        // Then
        XCTAssertEqual(self.navigationController.viewControllers.count, 2)
        XCTAssertEqual(self.navigationController.viewControllers.last?.title, "Test Roll")
    }

    @MainActor
    func test_whenDismissCreateRollCalled_shouldDismissModal() {
        // Given
        let viewController = self.sut.start()
        self.navigationController.viewControllers = [viewController]

        // Present create modal
        let createButton = viewController.navigationItem.rightBarButtonItem
        _ = createButton?.target?.perform(createButton!.action, with: createButton)

        // Wait for presentation
        let presentExpectation = XCTestExpectation(description: "Modal presented")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            presentExpectation.fulfill()
        }
        wait(for: [presentExpectation], timeout: 1.0)

        guard let presentedNav = navigationController.presentedViewController as? UINavigationController,
              let createVC = presentedNav.viewControllers.first else {
            XCTFail("Create view controller not presented")
            return
        }

        // When - tap cancel button
        let cancelButton = createVC.navigationItem.leftBarButtonItem
        _ = cancelButton?.target?.perform(cancelButton!.action, with: cancelButton)

        // Wait for dismissal
        let dismissExpectation = XCTestExpectation(description: "Modal dismissed")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            dismissExpectation.fulfill()
        }
        wait(for: [dismissExpectation], timeout: 1.0)

        // Then
        XCTAssertNil(self.navigationController.presentedViewController)
    }
}

// MARK: - Mock Dependencies

@available(iOS 15.0, *)
private struct MockFeedDependencies: FeedCoordinator.Dependencies {
    let rollRepository: RollRepositoryProtocol = MockRollRepository()
    let chefRepository: ChefRepositoryProtocol = MockChefRepository()
    let restaurantRepository: RestaurantRepositoryProtocol = MockRestaurantRepository()
    let hapticService: HapticFeedbackServicing = MockHapticFeedbackService()
}
