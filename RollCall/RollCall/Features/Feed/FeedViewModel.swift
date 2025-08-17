//
// FeedViewModel.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import Combine
import Foundation

@available(iOS 15.0, *)
public final class FeedViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published private(set) var viewState: FeedViewState = .initial

    // MARK: - Dependencies

    private let rollRepository: RollRepositoryProtocol
    private let chefRepository: ChefRepositoryProtocol
    private let restaurantRepository: RestaurantRepositoryProtocol
    private let hapticService: HapticFeedbackServicing

    // MARK: - Private Properties

    private var currentPage: Int = 0
    private let pageSize: Int = 20
    private var allRolls: [Roll] = []
    private var chefCache: [ChefID: Chef] = [:]
    private var restaurantCache: [RestaurantID: Restaurant] = [:]
    private var loadingTask: Task<Void, Never>?

    // MARK: - Navigation Events

    public let navigationEvent = PassthroughSubject<FeedNavigationEvent, Never>()

    // MARK: - Initialization

    public init(
        rollRepository: RollRepositoryProtocol,
        chefRepository: ChefRepositoryProtocol,
        restaurantRepository: RestaurantRepositoryProtocol,
        hapticService: HapticFeedbackServicing
    ) {
        self.rollRepository = rollRepository
        self.chefRepository = chefRepository
        self.restaurantRepository = restaurantRepository
        self.hapticService = hapticService
    }

    deinit {
        loadingTask?.cancel()
    }

    // MARK: - Public Methods

    public func onViewAppeared() {
        guard self.viewState.rolls.isEmpty else {
            return
        }
        loadInitialContent()
    }

    public func onRefreshRequested() {
        Task { [weak self] in
            await self?.hapticService.impact(style: .light)
        }
        refreshContent()
    }

    public func onLoadMoreRequested() {
        guard !self.viewState.isLoading && self.viewState.hasMoreContent else {
            return
        }
        loadMoreContent()
    }

    public func onRollTapped(_ rollId: String) {
        Task { [weak self] in
            await self?.hapticService.impact(style: .light)
        }

        guard let roll = allRolls.first(where: { $0.id.value.uuidString == rollId }) else {
            return
        }
        self.navigationEvent.send(.showRollDetail(roll))
    }

    public func onCreateRollTapped() {
        Task { [weak self] in
            await self?.hapticService.impact(style: .light)
        }
        self.navigationEvent.send(.createNewRoll)
    }

    public func onEditRoll(_ rollId: RollID) {
        Task { [weak self] in
            await self?.hapticService.impact(style: .light)
        }

        guard let roll = allRolls.first(where: { $0.id == rollId }) else {
            return
        }
        self.navigationEvent.send(.editRoll(roll))
    }

    public func onDeleteRoll(_ rollId: RollID) {
        Task { [weak self] in
            guard let self else { return }

            // Optimistically remove from UI
            await MainActor.run {
                var updatedRolls = self.viewState.rolls
                updatedRolls.removeAll { $0.id == rollId.value.uuidString }
                self.viewState = FeedViewState(
                    rolls: updatedRolls,
                    isLoading: self.viewState.isLoading,
                    isRefreshing: self.viewState.isRefreshing,
                    error: self.viewState.error,
                    hasMoreContent: self.viewState.hasMoreContent
                )
            }

            // Delete from repository
            do {
                try await self.rollRepository.deleteRoll(by: rollId)

                // Remove from cached data
                self.allRolls.removeAll { $0.id == rollId }

                // Haptic feedback for success
                await self.hapticService.notification(type: .success)

                // Check if we need to show empty state
                await MainActor.run {
                    if self.viewState.rolls.isEmpty {
                        self.viewState = .empty
                    }
                }
            } catch {
                // Restore on error
                await performRefresh()
                await self.hapticService.notification(type: .error)

                // Show error message
                await MainActor.run {
                    self.viewState = FeedViewState(
                        rolls: self.viewState.rolls,
                        isLoading: self.viewState.isLoading,
                        isRefreshing: self.viewState.isRefreshing,
                        error: "Failed to delete roll",
                        hasMoreContent: self.viewState.hasMoreContent
                    )
                }
            }
        }
    }
}

// MARK: - Private Methods

@available(iOS 15.0, *)
private extension FeedViewModel {
    func loadInitialContent() {
        self.loadingTask?.cancel()
        self.loadingTask = Task { [weak self] in
            await self?.performInitialLoad()
        }
    }

    @MainActor
    private func performInitialLoad() async {
        self.viewState = FeedViewState(isLoading: true)

        do {
            let rolls = try await rollRepository.fetchAllRolls()
            self.allRolls = rolls.sorted { $0.createdAt > $1.createdAt }

            await self.handleInitialLoadSuccess()
        } catch {
            self.handleInitialLoadError(error)
        }
    }

    @MainActor
    private func handleInitialLoadSuccess() async {
        let firstPageRolls = Array(allRolls.prefix(self.pageSize))
        await self.preloadDataForRolls(firstPageRolls)

        if self.allRolls.isEmpty {
            self.viewState = .empty
        } else {
            self.currentPage = 1
            let rollCards = await createRollCards(from: firstPageRolls)
            self.viewState = FeedViewState(
                rolls: rollCards,
                isLoading: false,
                hasMoreContent: self.allRolls.count > self.pageSize
            )
        }
    }

    @MainActor
    private func handleInitialLoadError(_ error: Error) {
        self.viewState = FeedViewState(
            isLoading: false,
            error: self.mapErrorToUserMessage(error)
        )
    }

    private func refreshContent() {
        self.loadingTask?.cancel()
        self.loadingTask = Task { [weak self] in
            await self?.performRefresh()
        }
    }

    @MainActor
    private func performRefresh() async {
        self.setRefreshingState()

        do {
            try await self.refreshRollsData()
            await self.handleRefreshSuccess()
        } catch {
            await self.handleRefreshError(error)
        }
    }

    @MainActor
    private func setRefreshingState() {
        self.viewState = FeedViewState(
            rolls: self.viewState.rolls,
            isLoading: false,
            isRefreshing: true,
            hasMoreContent: self.viewState.hasMoreContent
        )
    }

    private func refreshRollsData() async throws {
        let rolls = try await rollRepository.fetchAllRolls()
        await MainActor.run {
            self.allRolls = rolls.sorted { $0.createdAt > $1.createdAt }
            self.chefCache.removeAll()
            self.restaurantCache.removeAll()
        }
    }

    @MainActor
    private func handleRefreshSuccess() async {
        if self.allRolls.isEmpty {
            self.viewState = .empty
        } else {
            self.currentPage = 1
            let firstPageRolls = Array(allRolls.prefix(self.pageSize))
            await self.preloadDataForRolls(firstPageRolls)
            let rollCards = await createRollCards(from: firstPageRolls)

            self.viewState = FeedViewState(
                rolls: rollCards,
                isLoading: false,
                hasMoreContent: self.allRolls.count > self.pageSize
            )
        }

        await self.hapticService.notification(type: .success)
    }

    @MainActor
    private func handleRefreshError(_ error: Error) async {
        self.viewState = FeedViewState(
            rolls: self.viewState.rolls,
            isLoading: false,
            error: self.mapErrorToUserMessage(error),
            hasMoreContent: self.viewState.hasMoreContent
        )

        await self.hapticService.notification(type: .error)
    }

    private func loadMoreContent() {
        self.loadingTask?.cancel()
        self.loadingTask = Task { [weak self] in
            await self?.performLoadMore()
        }
    }

    @MainActor
    private func performLoadMore() async {
        let (startIndex, endIndex) = self.calculateLoadMoreIndices()

        guard startIndex < self.allRolls.count else {
            self.setNoMoreContentState()
            return
        }

        self.setLoadingMoreState()
        await self.loadNextPageRolls(startIndex: startIndex, endIndex: endIndex)
    }

    private func calculateLoadMoreIndices() -> (start: Int, end: Int) {
        let startIndex = self.currentPage * self.pageSize
        let endIndex = min(startIndex + self.pageSize, self.allRolls.count)
        return (startIndex, endIndex)
    }

    @MainActor
    private func setNoMoreContentState() {
        self.viewState = FeedViewState(
            rolls: self.viewState.rolls,
            isLoading: false,
            hasMoreContent: false
        )
    }

    @MainActor
    private func setLoadingMoreState() {
        self.viewState = FeedViewState(
            rolls: self.viewState.rolls,
            isLoading: true,
            hasMoreContent: true
        )
    }

    @MainActor
    private func loadNextPageRolls(startIndex: Int, endIndex: Int) async {
        let nextPageRolls = Array(allRolls[startIndex..<endIndex])
        await self.preloadDataForRolls(nextPageRolls)
        let newRollCards = await createRollCards(from: nextPageRolls)

        self.currentPage += 1

        self.viewState = FeedViewState(
            rolls: self.viewState.rolls + newRollCards,
            isLoading: false,
            hasMoreContent: endIndex < self.allRolls.count
        )
    }

    private func preloadDataForRolls(_ rolls: [Roll]) async {
        let result = await FeedDataPreloader.preloadDataForRolls(
            rolls,
            chefCache: self.chefCache,
            restaurantCache: self.restaurantCache,
            chefRepository: self.chefRepository,
            restaurantRepository: self.restaurantRepository
        )
        await MainActor.run {
            self.chefCache = result.chefCache
            self.restaurantCache = result.restaurantCache
        }
    }

    private func createRollCards(from rolls: [Roll]) async -> [RollCardViewState] {
        FeedCardBuilder.createRollCards(
            from: rolls,
            chefCache: self.chefCache,
            restaurantCache: self.restaurantCache
        )
    }

    private func mapErrorToUserMessage(_ error: Error) -> String {
        guard let appError = error as? AppError else {
            return "Unable to load feed. Please try again."
        }

        switch appError {
        case .networkError:
            return "No internet connection. Please check your network and try again."
        case .dataNotFound:
            return "Data not available. Please restart the app."
        case .unauthorized:
            return "Please log in again."
        case .notFound:
            return "Content not found."
        case .serverError:
            return "Server temporarily unavailable. Please try again later."
        default:
            return "Something went wrong. Please try again."
        }
    }
}

// MARK: - Navigation Events

@available(iOS 15.0, *)
public enum FeedNavigationEvent {
    case showRollDetail(Roll)
    case createNewRoll
    case editRoll(Roll)
}
