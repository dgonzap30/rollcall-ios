//
// MainTabCoordinator.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation
import SwiftUI
import UIKit

@available(iOS 15.0, *)
public final class MainTabCoordinator: MainTabCoordinating {
    // MARK: - Layout Constants

    private enum Layout {
        static let contentSpacing: CGFloat = Spacing.medium
        static let sectionSpacing: CGFloat = Spacing.xMassive
        static let itemSpacing: CGFloat = Spacing.small
        static let buttonHorizontalPadding: CGFloat = Spacing.xxLarge
        static let badgeHorizontalPadding: CGFloat = Spacing.xSmall
        static let badgeVerticalPadding: CGFloat = Spacing.Padding.small - 2
        static let cornerRadius: CGFloat = BorderRadius.medium
        static let smallCornerRadius: CGFloat = BorderRadius.small
    }

    // MARK: - Properties

    weak var delegate: MainTabCoordinatorDelegate?
    private let container: Container
    private let userPreferencesService: UserPreferencesServicing
    private var tabBarController: UITabBarController?
    private var childCoordinators: [Tab: Any] = [:]
    private var createRollCoordinator: CreateRollCoordinator?

    // MARK: - Initialization

    public init(container: Container) {
        self.container = container
        self.userPreferencesService = container.resolve(UserPreferencesServicing.self)
    }

    @MainActor
    public func start() -> some View {
        // Create tab bar controller
        let tabBar = UITabBarController()
        self.tabBarController = tabBar

        // Configure tab bar appearance
        self.configureTabBarAppearance(tabBar)

        // Setup tabs
        var viewControllers: [UIViewController] = []

        // Feed Tab
        let feedNav = UINavigationController()
        let feedCoordinator = FeedCoordinator(
            navigationController: feedNav,
            dependencies: FeedDependenciesAdapter(container: container)
        )
        self.childCoordinators[.feed] = feedCoordinator
        let feedVC = feedCoordinator.start()
        feedNav.viewControllers = [feedVC]
        feedNav.tabBarItem = UITabBarItem(
            title: Tab.feed.title,
            image: UIImage(systemName: Tab.feed.icon),
            selectedImage: UIImage(systemName: Tab.feed.selectedIcon)
        )
        viewControllers.append(feedNav)

        // Profile Tab (Placeholder)
        let profileNav = UINavigationController()
        let profileVC = self.createPlaceholderViewController(for: .profile)
        profileNav.viewControllers = [profileVC]
        profileNav.tabBarItem = UITabBarItem(
            title: Tab.profile.title,
            image: UIImage(systemName: Tab.profile.icon),
            selectedImage: UIImage(systemName: Tab.profile.selectedIcon)
        )
        viewControllers.append(profileNav)

        tabBar.viewControllers = viewControllers
        tabBar.selectedIndex = 0

        // Return wrapped tab bar controller
        return UIViewControllerWrapper(viewController: tabBar)
    }

    private func configureTabBarAppearance(_ tabBarController: UITabBarController) {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.rcRice50)

        // Normal state
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.rcSoy600)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.rcSoy600),
            .font: UIFont.systemFont(ofSize: 10, weight: .medium)
        ]

        // Selected state
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.rcPink500)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.rcPink500),
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold)
        ]

        tabBarController.tabBar.standardAppearance = appearance
        tabBarController.tabBar.scrollEdgeAppearance = appearance
    }

    private func createPlaceholderViewController(for tab: Tab) -> UIViewController {
        let placeholderView = VStack(spacing: Layout.contentSpacing) {
            Image(systemName: tab.icon)
                .font(.system(size: 60))
                .foregroundColor(.rcPink500.opacity(0.6))

            Text(tab.title)
                .font(.rcHeadline)
                .foregroundColor(.rcSeaweed800)

            Text("Coming Soon")
                .font(.rcBody)
                .foregroundColor(.rcSoy600)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.rcRice50)

        let hostingController = UIHostingController(rootView: placeholderView)
        hostingController.title = tab.title
        return hostingController
    }

    #if DEBUG
        @MainActor
        private func resetOnboarding() {
            // Reset onboarding preference
            self.userPreferencesService.setOnboardingCompleted(false)

            // Notify delegate to handle navigation
            self.delegate?.mainTabCoordinatorDidRequestReset(self)

            print("[MainTabCoordinator] Reset requested - notifying delegate")
        }
    #endif

    deinit {
        #if DEBUG
            print("[MainTabCoordinator] deinit")
        #endif
    }
}

// MARK: - MainTabCoordinating

@available(iOS 15.0, *)
extension MainTabCoordinator {
    @MainActor
    public func handleTabSelection(_ tab: Tab) {
        // Implement tab navigation in Phase 1
        #if DEBUG
            print("[MainTabCoordinator] Tab selected: \(tab.title)")
        #endif

        // Update selected tab based on available tabs
        switch tab {
        case .feed:
            self.tabBarController?.selectedIndex = 0
        case .profile:
            self.tabBarController?.selectedIndex = 1
        case .create:
            // Create tab triggers modal presentation instead
            self.showCreateRoll()
        }
    }

    @MainActor
    public func showCreateRoll() {
        // Create the coordinator with injected dependencies
        let coordinator = CreateRollCoordinator(
            rollRepository: container.resolve(RollRepositoryProtocol.self),
            chefRepository: self.container.resolve(ChefRepositoryProtocol.self),
            restaurantRepository: self.container.resolve(RestaurantRepositoryProtocol.self),
            hapticService: self.container.resolve(HapticFeedbackServicing.self),
            existingRoll: nil
        )
        coordinator.delegate = self
        self.createRollCoordinator = coordinator

        // Get the modal view controller
        let modalViewController = coordinator.start()

        // Present modally from the tab bar controller
        self.tabBarController?.present(modalViewController, animated: true)

        #if DEBUG
            print("[MainTabCoordinator] Presenting create roll modal")
        #endif
    }
}

// MARK: - CreateRollCoordinatorDelegate

@available(iOS 15.0, *)
extension MainTabCoordinator: CreateRollCoordinatorDelegate {
    public func createRollCoordinatorDidSave(_: CreateRollCoordinator, roll _: Roll) {
        // Clean up coordinator reference
        self.createRollCoordinator = nil

        // Refresh feed if it exists
        if self.childCoordinators[.feed] is FeedCoordinator {
            // The feed will automatically refresh via Core Data notifications
            #if DEBUG
                print("[MainTabCoordinator] Roll saved, feed should refresh automatically")
            #endif
        }

        // Notify delegate if needed
        // delegate?.mainTabCoordinatorDidCreateRoll(self, roll: roll)
    }

    public func createRollCoordinatorDidCancel(_: CreateRollCoordinator) {
        // Clean up coordinator reference
        self.createRollCoordinator = nil

        #if DEBUG
            print("[MainTabCoordinator] Create roll cancelled")
        #endif
    }
}
