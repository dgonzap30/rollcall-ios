//
// FeedCoordinator.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Combine
import SwiftUI
import UIKit

@available(iOS 15.0, *)
public final class FeedCoordinator {
    // MARK: - Properties

    private weak var navigationController: UINavigationController?
    private let dependencies: FeedDependencies
    private var cancellables = Set<AnyCancellable>()
    private var childCoordinators: [Any] = []

    // MARK: - Dependencies Protocol

    public protocol Dependencies {
        var rollRepository: RollRepositoryProtocol { get }
        var chefRepository: ChefRepositoryProtocol { get }
        var restaurantRepository: RestaurantRepositoryProtocol { get }
        var hapticService: HapticFeedbackServicing { get }
    }

    // MARK: - Initialization

    public init(
        navigationController: UINavigationController,
        dependencies: Dependencies
    ) {
        self.navigationController = navigationController
        self.dependencies = FeedDependencies(from: dependencies)
    }

    // MARK: - Public Methods

    @MainActor
    public func start() -> UIViewController {
        let viewModel = FeedViewModel(
            rollRepository: dependencies.rollRepository,
            chefRepository: self.dependencies.chefRepository,
            restaurantRepository: self.dependencies.restaurantRepository,
            hapticService: self.dependencies.hapticService
        )

        // Subscribe to navigation events
        viewModel.navigationEvent
            .sink { [weak self] event in
                self?.handle(event)
            }
            .store(in: &self.cancellables)

        let feedView = FeedView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: feedView)
        hostingController.title = "Feed"

        // Configure navigation bar
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.rcRice50)
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor(Color.rcSeaweed800),
            .font: UIFont.systemFont(ofSize: 18, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor(Color.rcSeaweed800),
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]

        hostingController.navigationItem.standardAppearance = appearance
        hostingController.navigationItem.scrollEdgeAppearance = appearance
        hostingController.navigationItem.compactAppearance = appearance

        // Add create button
        let createButton = UIBarButtonItem(
            image: UIImage(systemName: "plus.circle.fill"),
            style: .plain,
            target: self,
            action: #selector(self.createRollTapped)
        )
        createButton.tintColor = UIColor(Color.rcPink500)
        hostingController.navigationItem.rightBarButtonItem = createButton

        return hostingController
    }

    // MARK: - Private Methods

    private func handle(_ event: FeedNavigationEvent) {
        switch event {
        case let .showRollDetail(roll):
            self.showRollDetail(roll)
        case .createNewRoll:
            self.showCreateRoll()
        case let .editRoll(roll):
            self.showEditRoll(roll)
        }
    }

    private func showRollDetail(_ roll: Roll) {
        // MARK: MVP Implementation - Placeholder for roll detail view

        // Future: Implement dedicated RollDetailCoordinator with full detail functionality
        let detailView = Text("Roll Detail: \(roll.name)")
            .font(.largeTitle)
            .foregroundColor(.rcSeaweed800)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.rcRice50)

        let hostingController = UIHostingController(rootView: detailView)
        hostingController.title = roll.name
        self.navigationController?.pushViewController(hostingController, animated: true)
    }

    private func showCreateRoll() {
        // MARK: MVP Implementation - Placeholder for create roll view

        // Future: Implement dedicated CreateRollCoordinator with form and validation
        let createView = Text("Create New Roll")
            .font(.largeTitle)
            .foregroundColor(.rcSeaweed800)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.rcRice50)

        let hostingController = UIHostingController(rootView: createView)
        hostingController.title = "New Roll"
        let navController = UINavigationController(rootViewController: hostingController)

        // Add cancel button
        let cancelButton = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(self.dismissCreateRoll)
        )
        hostingController.navigationItem.leftBarButtonItem = cancelButton

        self.navigationController?.present(navController, animated: true)
    }

    private func showEditRoll(_ roll: Roll) {
        // Create edit coordinator with existing roll and injected dependencies
        let editCoordinator = CreateRollCoordinator(
            rollRepository: dependencies.rollRepository,
            chefRepository: self.dependencies.chefRepository,
            restaurantRepository: self.dependencies.restaurantRepository,
            hapticService: self.dependencies.hapticService,
            existingRoll: roll
        )
        editCoordinator.delegate = self
        self.childCoordinators.append(editCoordinator)

        // Present modal
        let modalViewController = editCoordinator.start()
        self.navigationController?.present(modalViewController, animated: true)
    }

    @objc
    private func createRollTapped() {
        self.showCreateRoll()
    }

    @objc
    private func dismissCreateRoll() {
        self.navigationController?.dismiss(animated: true)
    }
}

// MARK: - CreateRollCoordinatorDelegate

@available(iOS 15.0, *)
extension FeedCoordinator: CreateRollCoordinatorDelegate {
    public func createRollCoordinatorDidSave(_ coordinator: CreateRollCoordinator, roll _: Roll) {
        // Remove coordinator from child coordinators
        self.childCoordinators.removeAll { ($0 as? CreateRollCoordinator) === coordinator }

        // Feed will automatically refresh via Core Data notifications
        print("[FeedCoordinator] Roll saved/edited successfully")
    }

    public func createRollCoordinatorDidCancel(_ coordinator: CreateRollCoordinator) {
        // Remove coordinator from child coordinators
        self.childCoordinators.removeAll { ($0 as? CreateRollCoordinator) === coordinator }

        print("[FeedCoordinator] Edit cancelled")
    }
}

// MARK: - Dependencies Container

@available(iOS 15.0, *)
private struct FeedDependencies: FeedCoordinator.Dependencies {
    let rollRepository: RollRepositoryProtocol
    let chefRepository: ChefRepositoryProtocol
    let restaurantRepository: RestaurantRepositoryProtocol
    let hapticService: HapticFeedbackServicing

    init(from dependencies: FeedCoordinator.Dependencies) {
        self.rollRepository = dependencies.rollRepository
        self.chefRepository = dependencies.chefRepository
        self.restaurantRepository = dependencies.restaurantRepository
        self.hapticService = dependencies.hapticService
    }
}
