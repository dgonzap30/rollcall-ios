//
// CreateRollCoordinator.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import SwiftUI
import UIKit

/// Coordinator for the Create/Edit Roll flow
@available(iOS 15.0, *)
public protocol CreateRollCoordinatorDelegate: AnyObject {
    func createRollCoordinatorDidSave(_ coordinator: CreateRollCoordinator, roll: Roll)
    func createRollCoordinatorDidCancel(_ coordinator: CreateRollCoordinator)
}

@available(iOS 15.0, *)
public final class CreateRollCoordinator {
    // MARK: - Properties

    public weak var delegate: CreateRollCoordinatorDelegate?
    private weak var navigationController: UINavigationController?
    private let rollRepository: RollRepositoryProtocol
    private let chefRepository: ChefRepositoryProtocol
    private let restaurantRepository: RestaurantRepositoryProtocol
    private let hapticService: HapticFeedbackServicing
    private let existingRoll: Roll?
    private var viewModel: CreateRollViewModel?

    // MARK: - Initialization

    public init(
        rollRepository: RollRepositoryProtocol,
        chefRepository: ChefRepositoryProtocol,
        restaurantRepository: RestaurantRepositoryProtocol,
        hapticService: HapticFeedbackServicing,
        existingRoll: Roll? = nil
    ) {
        self.rollRepository = rollRepository
        self.chefRepository = chefRepository
        self.restaurantRepository = restaurantRepository
        self.hapticService = hapticService
        self.existingRoll = existingRoll
    }

    // MARK: - Coordinator

    public func start() -> UIViewController {
        let viewModel = CreateRollViewModel(
            rollRepository: rollRepository,
            chefRepository: chefRepository,
            restaurantRepository: restaurantRepository,
            hapticService: hapticService,
            existingRoll: existingRoll
        )
        viewModel.delegate = self
        self.viewModel = viewModel

        let view = CreateRollView(
            viewModel: viewModel,
            hapticService: hapticService,
            restaurantRepository: restaurantRepository
        )

        let hostingController = UIHostingController(rootView: view)
        hostingController.navigationItem.largeTitleDisplayMode = .never

        let navigationController = UINavigationController(rootViewController: hostingController)
        navigationController.modalPresentationStyle = UIModalPresentationStyle.formSheet
        navigationController.isModalInPresentation = false

        // Configure navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance

        self.navigationController = navigationController

        return navigationController
    }

    // MARK: - Public Methods

    public func dismissModal(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.navigationController?.dismiss(animated: animated, completion: completion)
    }
}

// MARK: - CreateRollViewModelDelegate

@available(iOS 15.0, *)
extension CreateRollCoordinator: CreateRollViewModelDelegate {
    public func createRollViewModelDidSave(_: CreateRollViewModel, roll: Roll) {
        self.dismissModal(animated: true) { [weak self] in
            guard let self else { return }
            self.delegate?.createRollCoordinatorDidSave(self, roll: roll)
        }
    }

    public func createRollViewModelDidCancel(_: CreateRollViewModel) {
        self.dismissModal(animated: true) { [weak self] in
            guard let self else { return }
            self.delegate?.createRollCoordinatorDidCancel(self)
        }
    }
}
