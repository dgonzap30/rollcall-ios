//
// MainTabViewModel.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Combine
import Foundation

@available(iOS 15.0, *)
public final class MainTabViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published private(set) var viewState: MainTabViewState

    // MARK: - Private Properties

    private var cancellables = Set<AnyCancellable>()
    weak var coordinator: MainTabCoordinating?

    // MARK: - Initialization

    public init(coordinator: MainTabCoordinating?) {
        self.coordinator = coordinator
        self.viewState = MainTabViewState()

        self.setupBindings()
    }

    // MARK: - Public Methods

    @MainActor
    public func onTabSelected(_ tab: Tab) {
        self.updateViewState { currentState in
            currentState.with(selectedTab: tab, error: .some(nil))
        }

        self.coordinator?.handleTabSelection(tab)
    }

    @MainActor
    public func onCreateRollTapped() {
        self.coordinator?.showCreateRoll()
    }

    // MARK: - Private Methods

    private func setupBindings() {
        // Future: Subscribe to feed updates, notifications, etc.
        // This is where we'd observe services for badge counts
    }

    private func updateBadgeCounts(feed: Int, profile: Int) {
        Task { @MainActor [weak self] in
            self?.updateViewState { currentState in
                currentState.with(feedBadgeCount: feed, profileBadgeCount: profile)
            }
        }
    }

    @MainActor
    private func updateViewState(transform: (MainTabViewState) -> MainTabViewState) {
        self.viewState = transform(self.viewState)
    }

    @MainActor
    public func dismissError() {
        self.updateViewState { currentState in
            currentState.with(error: .some(nil))
        }
    }

    deinit {
        #if DEBUG
            print("[MainTabViewModel] deinit")
        #endif
    }
}
