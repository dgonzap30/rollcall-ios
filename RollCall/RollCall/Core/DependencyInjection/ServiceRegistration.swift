//
// ServiceRegistration.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

@available(iOS 15.0, macOS 12.0, *)
public final class ServiceRegistration {
    private let container: Container
    private var coreDataStack: CoreDataStack?

    public init(container: Container) {
        self.container = container
    }

    /// Register all services for the application
    public func registerServices() {
        self.registerCoreDataStack()
        self.registerCoreServices()
        self.registerNetworkingServices()
        self.registerRepositoryServices()
        self.registerPlatformServices()
    }

    /// Register all services for testing (with mocks)
    public func registerTestServices() {
        self.registerTestCoreDataStack()
        self.registerMockServices()
        self.registerTestRepositoryServices()
        self.registerPlatformServices()
    }

    // MARK: - Core Data Stack

    private func registerCoreDataStack() {
        self.coreDataStack = CoreDataStack()
        self.container.registerSingleton(CoreDataStack.self) { [weak self] in
            self?.coreDataStack ?? CoreDataStack()
        }
    }

    private func registerTestCoreDataStack() {
        self.coreDataStack = CoreDataStack.makeTestStack()
        self.container.registerSingleton(CoreDataStack.self) { [weak self] in
            self?.coreDataStack ?? CoreDataStack.makeTestStack()
        }
    }

    // MARK: - Core Services

    private func registerCoreServices() {
        // Auth Service
        self.container.registerSingleton(AuthServicing.self) {
            AuthService()
        }

        // Haptic Feedback Service
        self.container.registerSingleton(HapticFeedbackServicing.self) {
            #if os(iOS)
                HapticFeedbackService()
            #else
                NoOpHapticFeedbackService()
            #endif
        }

        // User Preferences Service
        self.container.registerSingleton(UserPreferencesServicing.self) {
            UserPreferencesService()
        }

        // Accessibility Service
        self.container.registerSingleton(AccessibilityServicing.self) {
            AccessibilityService()
        }
    }

    private func registerMockServices() {
        // Mock Auth Service for testing
        self.container.registerSingleton(AuthServicing.self) {
            MockAuthService()
        }

        // Mock Haptic Service for testing
        self.container.registerSingleton(HapticFeedbackServicing.self) {
            NoOpHapticFeedbackService()
        }

        // Mock User Preferences Service for testing
        self.container.registerSingleton(UserPreferencesServicing.self) {
            UserPreferencesService(userDefaults: UserDefaults(suiteName: "test.rollcall")!)
        }

        // Mock Accessibility Service for testing
        self.container.registerSingleton(AccessibilityServicing.self) {
            NoOpAccessibilityService()
        }
    }

    // MARK: - Repository Services

    private func registerRepositoryServices() {
        // Using CoreData repositories for persistent storage
        guard let coreDataStack else {
            fatalError("CoreDataStack must be initialized before registering repository services")
        }

        self.container.registerSingleton(RollRepositoryProtocol.self) { [weak coreDataStack] in
            guard let stack = coreDataStack else {
                fatalError("CoreDataStack was deallocated")
            }
            return CoreDataRollRepository(coreDataStack: stack)
        }

        self.container.registerSingleton(ChefRepositoryProtocol.self) { [weak coreDataStack] in
            guard let stack = coreDataStack else {
                fatalError("CoreDataStack was deallocated")
            }
            return CoreDataChefRepository(coreDataStack: stack)
        }

        self.container.registerSingleton(RestaurantRepositoryProtocol.self) { [weak coreDataStack] in
            guard let stack = coreDataStack else {
                fatalError("CoreDataStack was deallocated")
            }
            return CoreDataRestaurantRepository(coreDataStack: stack)
        }
    }

    private func registerTestRepositoryServices() {
        // Mock repositories for testing
        self.container.registerSingleton(RollRepositoryProtocol.self) {
            MockRollRepository()
        }

        self.container.registerSingleton(ChefRepositoryProtocol.self) {
            MockChefRepository()
        }

        self.container.registerSingleton(RestaurantRepositoryProtocol.self) {
            MockRestaurantRepository()
        }
    }

    // MARK: - Networking Services

    private func registerNetworkingServices() {
        // Networking services will be implemented when backend is ready
        // Planned services:
        // - APIClient for REST API communication
        // - NetworkMonitor for connectivity status
        // - URLSession configuration
        // - Request/Response interceptors
        // Implementation tracked in FUTURE_DEV.md
    }

    // MARK: - Platform Services

    private func registerPlatformServices() {
        // Platform-specific services that are always the same

        // Location Service (when implemented)
        // container.registerSingleton(LocationServicing.self) {
        //     LocationService()
        // }

        // Image Processing Service (when implemented)
        // container.registerSingleton(ImageProcessingServicing.self) {
        //     ImageProcessingService()
        // }
    }
}

// Services enum removed - use explicit dependency injection through Container parameter instead
