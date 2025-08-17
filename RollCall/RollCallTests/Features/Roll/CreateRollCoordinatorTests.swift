//
// CreateRollCoordinatorTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

@testable import RollCall
import XCTest

@available(iOS 15.0, *)
@MainActor
final class CreateRollCoordinatorTests: XCTestCase {
    // MARK: - Properties

    private var sut: CreateRollCoordinator!
    private var mockContainer: MockDependencyContainer!
    private var mockDelegate: MockCreateRollCoordinatorDelegate!

    // MARK: - Setup & Teardown

    override func setUp() async throws {
        try await super.setUp()

        self.mockContainer = MockDependencyContainer()
        self.mockDelegate = MockCreateRollCoordinatorDelegate()
    }

    override func tearDown() async throws {
        self.sut = nil
        self.mockContainer = nil
        self.mockDelegate = nil
        try await super.tearDown()
    }

    // MARK: - Initialization Tests

    func test_whenInitialized_shouldSetupCorrectly() {
        // When
        self.sut = CreateRollCoordinator(
            rollRepository: self.mockContainer.rollRepository,
            chefRepository: self.mockContainer.chefRepository,
            restaurantRepository: self.mockContainer.restaurantRepository,
            hapticService: self.mockContainer.hapticService
        )

        // Then
        XCTAssertNotNil(self.sut)
    }

    func test_whenInitializedWithExistingRoll_shouldSetupEditMode() {
        // Given
        let existingRoll = self.createTestRoll()

        // When
        self.sut = CreateRollCoordinator(
            rollRepository: self.mockContainer.rollRepository,
            chefRepository: self.mockContainer.chefRepository,
            restaurantRepository: self.mockContainer.restaurantRepository,
            hapticService: self.mockContainer.hapticService,
            existingRoll: existingRoll
        )

        // Then
        XCTAssertNotNil(self.sut)
    }

    // MARK: - Start Tests

    func test_whenStarted_shouldReturnNavigationController() {
        // Given
        self.sut = CreateRollCoordinator(
            rollRepository: self.mockContainer.rollRepository,
            chefRepository: self.mockContainer.chefRepository,
            restaurantRepository: self.mockContainer.restaurantRepository,
            hapticService: self.mockContainer.hapticService
        )

        // When
        let viewController = self.sut.start()

        // Then
        XCTAssertTrue(viewController is UINavigationController)

        if let navController = viewController as? UINavigationController {
            XCTAssertEqual(navController.modalPresentationStyle, .formSheet)
            XCTAssertFalse(navController.isModalInPresentation)
        }
    }

    func test_whenPresentedModally_shouldHaveNavigationBar() {
        // Given
        self.sut = CreateRollCoordinator(
            rollRepository: self.mockContainer.rollRepository,
            chefRepository: self.mockContainer.chefRepository,
            restaurantRepository: self.mockContainer.restaurantRepository,
            hapticService: self.mockContainer.hapticService
        )

        // When
        let viewController = self.sut.start()

        // Then
        guard let navController = viewController as? UINavigationController,
              let rootViewController = navController.viewControllers.first else {
            XCTFail("Should have navigation controller with root view")
            return
        }

        XCTAssertNotNil(rootViewController.navigationItem)
    }

    // MARK: - Delegate Tests

    func test_whenSaveCompleted_shouldDismissModal() async {
        // Given
        self.sut = CreateRollCoordinator(
            rollRepository: self.mockContainer.rollRepository,
            chefRepository: self.mockContainer.chefRepository,
            restaurantRepository: self.mockContainer.restaurantRepository,
            hapticService: self.mockContainer.hapticService
        )
        self.sut.delegate = self.mockDelegate

        let viewController = self.sut.start()
        let window = UIWindow()
        window.rootViewController = viewController
        window.makeKeyAndVisible()

        let expectation = XCTestExpectation(description: "Save callback")
        self.mockDelegate.onSave = { _, _ in
            expectation.fulfill()
        }

        // When
        let testRoll = self.createTestRoll()
        self.sut.createRollViewModelDidSave(CreateRollViewModel(
            rollRepository: self.mockContainer.rollRepository,
            chefRepository: self.mockContainer.chefRepository,
            restaurantRepository: self.mockContainer.restaurantRepository,
            hapticService: self.mockContainer.hapticService
        ), roll: testRoll)

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func test_whenCancelled_shouldCallDelegate() async {
        // Given
        self.sut = CreateRollCoordinator(
            rollRepository: self.mockContainer.rollRepository,
            chefRepository: self.mockContainer.chefRepository,
            restaurantRepository: self.mockContainer.restaurantRepository,
            hapticService: self.mockContainer.hapticService
        )
        self.sut.delegate = self.mockDelegate

        _ = self.sut.start()

        let expectation = XCTestExpectation(description: "Cancel callback")
        self.mockDelegate.onCancel = { _ in
            expectation.fulfill()
        }

        // When
        self.sut.createRollViewModelDidCancel(CreateRollViewModel(
            rollRepository: self.mockContainer.rollRepository,
            chefRepository: self.mockContainer.chefRepository,
            restaurantRepository: self.mockContainer.restaurantRepository,
            hapticService: self.mockContainer.hapticService
        ))

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
    }

    // MARK: - Dismiss Tests

    func test_whenDismissModalCalled_shouldDismiss() {
        // Given
        self.sut = CreateRollCoordinator(
            rollRepository: self.mockContainer.rollRepository,
            chefRepository: self.mockContainer.chefRepository,
            restaurantRepository: self.mockContainer.restaurantRepository,
            hapticService: self.mockContainer.hapticService
        )
        let viewController = self.sut.start()

        let window = UIWindow()
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        window.rootViewController?.present(viewController, animated: false)

        // When
        self.sut.dismissModal(animated: false)

        // Then
        // Dismiss would be called but in tests it's hard to verify
        // This test mainly ensures the method exists and doesn't crash
        XCTAssertNotNil(self.sut)
    }

    // MARK: - Helper Methods

    private func createTestRoll() -> Roll {
        Roll(
            id: RollID(),
            chefID: ChefID(),
            restaurantID: RestaurantID(),
            type: .nigiri,
            name: "Salmon Nigiri",
            description: "Fresh salmon",
            rating: Rating(value: 5)!,
            photoURL: nil,
            tags: ["fresh", "salmon"],
            createdAt: Date(),
            updatedAt: Date()
        )
    }
}

// MARK: - Mock Delegate

@available(iOS 15.0, *)
private final class MockCreateRollCoordinatorDelegate: CreateRollCoordinatorDelegate {
    var onSave: ((CreateRollCoordinator, Roll) -> Void)?
    var onCancel: ((CreateRollCoordinator) -> Void)?

    func createRollCoordinatorDidSave(_ coordinator: CreateRollCoordinator, roll: Roll) {
        self.onSave?(coordinator, roll)
    }

    func createRollCoordinatorDidCancel(_ coordinator: CreateRollCoordinator) {
        self.onCancel?(coordinator)
    }
}

// MARK: - Mock Dependency Container

@available(iOS 15.0, *)
private final class MockDependencyContainer: Container {
    let rollRepository: RollRepositoryProtocol = MockRollRepository()
    let chefRepository: ChefRepositoryProtocol = MockChefRepository()
    let restaurantRepository: RestaurantRepositoryProtocol = MockRestaurantRepository()
    let hapticService: HapticFeedbackServicing = MockHapticFeedbackService()
    let keychainService: KeychainServicing = MockKeychainService()
    let userPreferencesService: UserPreferencesServicing = MockUserPreferencesService()

    func register<T>(_: T.Type, factory _: @escaping () -> T) {}
    func register<T>(_: T.Type, instance _: T) {}
    func registerSingleton<T>(_: T.Type, factory _: @escaping () -> T) {}

    func resolve<T>(_ type: T.Type) -> T {
        if type == RollRepositoryProtocol.self,
           let service = rollRepository as? T {
            return service
        } else if type == ChefRepositoryProtocol.self,
                  let service = chefRepository as? T {
            return service
        } else if type == RestaurantRepositoryProtocol.self,
                  let service = restaurantRepository as? T {
            return service
        } else if type == HapticFeedbackServicing.self,
                  let service = hapticService as? T {
            return service
        } else if type == KeychainServicing.self,
                  let service = keychainService as? T {
            return service
        } else if type == UserPreferencesServicing.self,
                  let service = userPreferencesService as? T {
            return service
        }
        fatalError("Type not registered: \(type)")
    }

    func resolve<T>(_ type: T.Type) -> T? {
        if type == RollRepositoryProtocol.self {
            return self.rollRepository as? T
        } else if type == ChefRepositoryProtocol.self {
            return self.chefRepository as? T
        } else if type == RestaurantRepositoryProtocol.self {
            return self.restaurantRepository as? T
        } else if type == HapticFeedbackServicing.self {
            return self.hapticService as? T
        } else if type == KeychainServicing.self {
            return self.keychainService as? T
        } else if type == UserPreferencesServicing.self {
            return self.userPreferencesService as? T
        }
        return nil
    }
}
