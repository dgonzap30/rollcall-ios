//
// AppCoordinator.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation
import SwiftUI
#if os(iOS)
    import UIKit
#endif

@available(iOS 15.0, macOS 12.0, *)
public final class AppCoordinator: ObservableObject {
    // MARK: - Properties

    @Published private(set) var isOnboarding: Bool

    // AppCoordinator is the only allowed singleton per CLAUDE.md
    public static let shared = AppCoordinator()

    // Container for dependency injection
    private let container: Container
    private let serviceRegistration: ServiceRegistration
    private let userPreferencesService: UserPreferencesServicing

    // Coordinator retention to prevent recreation
    private var onboardingCoordinator: OnboardingCoordinator?
    private var mainTabCoordinator: MainTabCoordinator?

    // MARK: - Initialization

    private init() {
        let diContainer = DIContainer()
        self.container = diContainer
        self.serviceRegistration = ServiceRegistration(container: diContainer)

        // Register all services
        #if DEBUG
            self.serviceRegistration.registerTestServices()
        #else
            self.serviceRegistration.registerServices()
        #endif

        // Resolve service from container (following OnboardingCoordinator pattern)
        self.userPreferencesService = self.container.resolve(UserPreferencesServicing.self)

        // Initialize state from UserDefaults
        self.isOnboarding = !self.userPreferencesService.hasCompletedOnboarding

        // Perform security migrations on startup
        self.performSecurityMigrations()
    }

    // MARK: - Public Methods

    @MainActor
    public func start() -> some View {
        // Use retained coordinators for consistency
        if self.isOnboarding {
            return AnyView(self.createOnboardingView())
        } else {
            return AnyView(self.createMainView())
        }
    }

    @MainActor
    func createOnboardingView() -> some View {
        if self.onboardingCoordinator == nil {
            let coordinator = OnboardingCoordinator(container: container)
            coordinator.delegate = self
            self.onboardingCoordinator = coordinator
        }
        guard let coordinator = self.onboardingCoordinator else {
            fatalError("Onboarding coordinator should be initialized")
        }
        return AnyView(coordinator.start())
    }

    @MainActor
    func createMainView() -> some View {
        if self.mainTabCoordinator == nil {
            let coordinator = MainTabCoordinator(container: container)
            coordinator.delegate = self
            self.mainTabCoordinator = coordinator
        }
        guard let coordinator = self.mainTabCoordinator else {
            fatalError("Main tab coordinator should be initialized")
        }
        return AnyView(coordinator.start())
    }

    // MARK: - Private Methods

    private func performSecurityMigrations() {
        Task { [weak self] in
            guard self != nil else { return }

            let migrationService = AppSecurityMigrationService()

            do {
                try await migrationService.performMigrationsIfNeeded()
                #if DEBUG
                    print("[AppCoordinator] Security migrations completed successfully")
                #endif
            } catch {
                // Log error but don't prevent app startup
                #if DEBUG
                    print("[AppCoordinator] Security migration failed: \(error)")
                #endif
                // In production, this would be logged to crash reporting service
            }
        }
    }

    private func completeOnboarding() {
        #if DEBUG
            print("[AppCoordinator] completeOnboarding called - transitioning to main app")
        #endif

        Task { @MainActor [weak self] in
            guard let self else { return }

            // Update state to trigger UI transition
            withAnimation(AnimationTokens.Curve.easeInOut) {
                self.isOnboarding = false
            }

            // Use Task.sleep for modern async/await pattern
            try? await Task.sleep(nanoseconds: UInt64(AnimationTokens.Duration.medium * 1_000_000_000))

            // Clean up coordinator after animation completes
            self.onboardingCoordinator = nil
        }
    }
}

// MARK: - OnboardingCoordinatorDelegate

@available(iOS 15.0, macOS 12.0, *)
extension AppCoordinator: OnboardingCoordinatorDelegate {
    func onboardingCoordinatorDidFinish(_: OnboardingCoordinator) {
        #if DEBUG
            print("[AppCoordinator] onboardingCoordinatorDidFinish called")
        #endif

        // Update UserDefaults through service
        self.userPreferencesService.setOnboardingCompleted(true)

        // Trigger UI transition
        self.completeOnboarding()
    }
}

// MARK: - MainTabCoordinatorDelegate

@available(iOS 15.0, macOS 12.0, *)
extension AppCoordinator: MainTabCoordinatorDelegate {
    @MainActor
    public func mainTabCoordinatorDidRequestReset(_: MainTabCoordinator) {
        #if DEBUG
            print("[AppCoordinator] mainTabCoordinatorDidRequestReset called - resetting to onboarding")
        #endif

        // Reset preferences through service
        self.userPreferencesService.setOnboardingCompleted(false)

        // Update state to trigger UI transition
        withAnimation(AnimationTokens.Curve.easeInOut) {
            self.isOnboarding = true
        }

        // Clean up main tab coordinator after animation
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(AnimationTokens.Duration.medium * 1_000_000_000))
            self?.mainTabCoordinator = nil
        }
    }
}

// MARK: - Technical Debt Documentation

/*
 TECHNICAL DEBT: Singleton Pattern

 Current State:
 - AppCoordinator uses singleton pattern as the ONLY allowed singleton per CLAUDE.md (A-6)
 - This is intentional for app lifecycle management at the root level

 Trade-offs:
 - ✅ Simple app initialization and state management
 - ✅ Guaranteed single source of truth for navigation
 - ❌ Makes unit testing more difficult
 - ❌ Cannot test multiple app states in parallel

 Future Migration Path:
 1. Move singleton creation to SceneDelegate/AppDelegate
 2. Inject AppCoordinator into RootView as dependency
 3. Create AppCoordinatorProtocol for testing
 4. Update all references to use injected instance

 Timeline: Consider migration after MVP when app architecture stabilizes
 */
