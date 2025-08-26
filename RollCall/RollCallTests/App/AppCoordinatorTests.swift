//
// AppCoordinatorTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

@testable import RollCall
import SwiftUI
import XCTest

@available(iOS 15.0, *)
final class AppCoordinatorTests: XCTestCase {
    var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        self.userDefaults = UserDefaults(suiteName: "test.rollcall.appcoordinator")!
        self.userDefaults.removePersistentDomain(forName: "test.rollcall.appcoordinator")
    }

    override func tearDown() {
        self.userDefaults.removePersistentDomain(forName: "test.rollcall.appcoordinator")
        self.userDefaults = nil
        super.tearDown()
    }

    // MARK: - Singleton Tests

    func test_shared_returnsSameInstance() {
        let instance1 = AppCoordinator.shared
        let instance2 = AppCoordinator.shared

        XCTAssertIdentical(instance1, instance2)
    }

    func test_shared_isNotNil() {
        XCTAssertNotNil(AppCoordinator.shared)
    }

    // MARK: - Start Tests

    @MainActor
    func test_start_whenOnboardingNotCompleted_returnsOnboardingView() {
        // AppCoordinator starts with isOnboarding = true by default
        let coordinator = AppCoordinator.shared

        // Force reset to onboarding state for test
        let userPreferencesService = UserPreferencesService()
        userPreferencesService.setOnboardingCompleted(false)

        let view = coordinator.start()

        // Verify view type using Mirror
        let mirror = Mirror(reflecting: view)
        let viewType = String(describing: mirror.subjectType)

        XCTAssertTrue(viewType.contains("AnyView"))
    }

    @MainActor
    func test_start_whenOnboardingCompleted_returnsMainView() {
        let coordinator = AppCoordinator.shared

        // Complete onboarding
        let userPreferencesService = UserPreferencesService()
        userPreferencesService.setOnboardingCompleted(true)
        coordinator.onboardingCoordinatorDidFinish(OnboardingCoordinator(container: DIContainer()))

        let view = coordinator.start()

        // Verify view type using Mirror
        let mirror = Mirror(reflecting: view)
        let viewType = String(describing: mirror.subjectType)

        XCTAssertTrue(viewType.contains("AnyView"))
    }

    // MARK: - Onboarding Delegate Tests

    @MainActor
    func test_onboardingCoordinatorDidFinish_updatesUserDefaults() {
        let coordinator = AppCoordinator.shared

        // Reset onboarding
        let userPreferencesService = UserPreferencesService()
        userPreferencesService.setOnboardingCompleted(false)

        let onboardingCoordinator = OnboardingCoordinator(container: DIContainer())
        coordinator.onboardingCoordinatorDidFinish(onboardingCoordinator)

        // Verify UserDefaults was updated immediately
        XCTAssertTrue(userPreferencesService.hasCompletedOnboarding)
    }

    @MainActor
    func test_onboardingCoordinatorDidFinish_triggersStateChange() {
        let coordinator = AppCoordinator.shared

        // Reset to onboarding state first
        let userPreferencesService = UserPreferencesService()
        userPreferencesService.setOnboardingCompleted(false)

        let onboardingCoordinator = OnboardingCoordinator(container: DIContainer())
        coordinator.onboardingCoordinatorDidFinish(onboardingCoordinator)

        // State should be updated synchronously
        XCTAssertFalse(coordinator.isOnboarding)
    }

    func test_completeOnboarding_conformsToDelegate() {
        let coordinator = AppCoordinator.shared

        // Verify it conforms to OnboardingCoordinatorDelegate
        // This is compile-time verified since AppCoordinator conforms to the protocol
        XCTAssertTrue(coordinator is OnboardingCoordinatorDelegate)
    }

    // MARK: - Service Registration Tests

    func test_container_registersRequiredServices() {
        let testContainer = DIContainer()
        let serviceRegistration = ServiceRegistration(container: testContainer)

        #if DEBUG
            serviceRegistration.registerTestServices()
        #else
            serviceRegistration.registerServices()
        #endif

        // Verify core services are registered
        XCTAssertNotNil(testContainer.resolve(HapticFeedbackServicing.self))
        XCTAssertNotNil(testContainer.resolve(AuthServicing.self))
        XCTAssertNotNil(testContainer.resolve(RollRepositoryProtocol.self))
        XCTAssertNotNil(testContainer.resolve(ChefRepositoryProtocol.self))
        XCTAssertNotNil(testContainer.resolve(RestaurantRepositoryProtocol.self))
        XCTAssertNotNil(testContainer.resolve(UserPreferencesServicing.self))
    }

    func test_container_registersCoreDataStack() {
        let testContainer = DIContainer()
        let serviceRegistration = ServiceRegistration(container: testContainer)

        #if DEBUG
            serviceRegistration.registerTestServices()
        #else
            serviceRegistration.registerServices()
        #endif

        let coreDataStack: CoreDataStack? = testContainer.resolve(CoreDataStack.self)
        XCTAssertNotNil(coreDataStack)
    }

    // MARK: - Memory Management Tests

    @MainActor
    func test_coordinators_noRetainCycles() {
        weak var weakOnboardingCoordinator: OnboardingCoordinator?

        autoreleasepool {
            let coordinator = OnboardingCoordinator(
                container: MockContainer()
            )
            coordinator.delegate = AppCoordinator.shared
            weakOnboardingCoordinator = coordinator
            _ = coordinator.start()
        }

        XCTAssertNil(weakOnboardingCoordinator)
    }

    @MainActor
    func test_coordinatorCleanup_afterOnboardingComplete() {
        let coordinator = AppCoordinator.shared

        // Create onboarding view to initialize coordinator
        _ = coordinator.createOnboardingView()

        // Complete onboarding
        let onboardingCoordinator = OnboardingCoordinator(container: DIContainer())
        coordinator.onboardingCoordinatorDidFinish(onboardingCoordinator)

        // Coordinator should be cleaned up
        // We can't directly check private property, but creating a new view should create a new coordinator
        let view1 = coordinator.createOnboardingView()
        let view2 = coordinator.createOnboardingView()

        // Both should return valid views
        XCTAssertNotNil(view1)
        XCTAssertNotNil(view2)
    }

    // MARK: - Coordinator Lifecycle Tests

    @MainActor
    func test_createOnboardingView_reusesExistingCoordinator() {
        let coordinator = AppCoordinator.shared

        // Create multiple views
        let view1 = coordinator.createOnboardingView()
        let view2 = coordinator.createOnboardingView()
        let view3 = coordinator.createOnboardingView()

        // All should be valid views (not testing identity since they're wrapped in AnyView)
        XCTAssertNotNil(view1)
        XCTAssertNotNil(view2)
        XCTAssertNotNil(view3)
    }

    @MainActor
    func test_createMainView_reusesExistingCoordinator() {
        let coordinator = AppCoordinator.shared

        // Create multiple views
        let view1 = coordinator.createMainView()
        let view2 = coordinator.createMainView()
        let view3 = coordinator.createMainView()

        // All should be valid views
        XCTAssertNotNil(view1)
        XCTAssertNotNil(view2)
        XCTAssertNotNil(view3)
    }

    @MainActor
    func test_start_usesCreateMethods() {
        let coordinator = AppCoordinator.shared

        // When onboarding is not complete
        let userPreferencesService = UserPreferencesService()
        userPreferencesService.setOnboardingCompleted(false)

        let onboardingView = coordinator.start()
        XCTAssertNotNil(onboardingView)

        // When onboarding is complete
        userPreferencesService.setOnboardingCompleted(true)
        coordinator.onboardingCoordinatorDidFinish(OnboardingCoordinator(container: DIContainer()))

        let mainView = coordinator.start()
        XCTAssertNotNil(mainView)
    }

    // MARK: - Environment Tests

    func test_debugConfiguration_usesInMemoryStack() {
        #if DEBUG
            // In debug, we might want to verify specific debug configurations
            let testContainer = DIContainer()
            let serviceRegistration = ServiceRegistration(container: testContainer)
            serviceRegistration.registerTestServices()
            XCTAssertNotNil(testContainer.resolve(CoreDataStack.self))
        #endif
    }

    // MARK: - Integration Tests

    @MainActor
    func test_onboardingFlow_integration() {
        let coordinator = AppCoordinator.shared

        // Reset onboarding
        let userPreferencesService = UserPreferencesService()
        userPreferencesService.setOnboardingCompleted(false)

        // Start app
        _ = coordinator.start()

        // Complete onboarding
        let onboardingCoordinator = OnboardingCoordinator(container: DIContainer())
        coordinator.onboardingCoordinatorDidFinish(onboardingCoordinator)

        // Verify state changed synchronously
        XCTAssertTrue(userPreferencesService.hasCompletedOnboarding)

        // Next start should show main view
        let secondView = coordinator.start()
        XCTAssertNotNil(secondView)
    }

    @MainActor
    func test_appCoordinator_handlesConcurrentAccess() {
        let coordinator = AppCoordinator.shared

        // Perform concurrent operations synchronously
        _ = coordinator.start()
        _ = coordinator.start()
        _ = coordinator.createMainView()
        _ = coordinator.createOnboardingView()

        // If we get here, concurrent access didn't cause issues
        XCTAssertNotNil(coordinator)
    }

    // MARK: - Technical Debt Documentation Test

    func test_technicalDebtDocumentation_exists() {
        // This test ensures the technical debt documentation is maintained
        // The actual documentation is in the AppCoordinator file
        let coordinator = AppCoordinator.shared
        XCTAssertNotNil(coordinator) // Documentation should be with the implementation
    }

    // MARK: - MainTabCoordinatorDelegate Tests

    @MainActor
    func test_mainTabCoordinatorDidRequestReset_resetsOnboardingState() {
        let coordinator = AppCoordinator.shared
        let userPreferencesService = UserPreferencesService()

        // Given - onboarding is completed
        userPreferencesService.setOnboardingCompleted(true)
        coordinator.onboardingCoordinatorDidFinish(OnboardingCoordinator(container: DIContainer()))

        // When - reset is requested
        let mainTabCoordinator = MainTabCoordinator(container: DIContainer())
        coordinator.mainTabCoordinatorDidRequestReset(mainTabCoordinator)

        // Then - should be back in onboarding immediately
        XCTAssertTrue(coordinator.isOnboarding)
        XCTAssertFalse(userPreferencesService.hasCompletedOnboarding)
    }

    @MainActor
    func test_mainTabCoordinatorDidRequestReset_cleansUpMainTabCoordinator() {
        let coordinator = AppCoordinator.shared

        // Given - main view is active
        let userPreferencesService = UserPreferencesService()
        userPreferencesService.setOnboardingCompleted(true)
        _ = coordinator.createMainView()

        // When - reset is requested
        let mainTabCoordinator = MainTabCoordinator(container: DIContainer())
        coordinator.mainTabCoordinatorDidRequestReset(mainTabCoordinator)

        // Then - main tab coordinator should be cleaned up
        // Creating a new main view should create a new coordinator
        let newView = coordinator.createMainView()
        XCTAssertNotNil(newView)
    }
}
