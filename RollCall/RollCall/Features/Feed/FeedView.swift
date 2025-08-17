//
// FeedView.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

#if canImport(SwiftUI)
    import SwiftUI

    @available(iOS 15.0, *)
    @MainActor
    public struct FeedView: View {
        @ObservedObject private var viewModel: FeedViewModel
        @State private var hasAppeared = false

        public init(viewModel: FeedViewModel) {
            self.viewModel = viewModel
        }

        public var body: some View {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color.rcBackgroundCenter,
                        Color.rcBackgroundBase,
                        Color.rcBackgroundEdge
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                self.content
            }
            .onAppear {
                if !self.hasAppeared {
                    self.hasAppeared = true
                    self.viewModel.onViewAppeared()
                }
            }
        }

        @ViewBuilder
        private var content: some View {
            if self.viewModel.viewState.isLoading && self.viewModel.viewState.rolls.isEmpty {
                FeedLoadingView()
            } else if let error = viewModel.viewState.error {
                self.errorView(message: error)
            } else if self.viewModel.viewState.rolls.isEmpty {
                FeedEmptyStateView(
                    message: self.viewModel.viewState.emptyStateMessage,
                    onCreateRollTapped: self.viewModel.onCreateRollTapped
                )
            } else {
                self.feedList
            }
        }

        private var feedList: some View {
            ScrollView {
                LazyVStack(spacing: Spacing.medium) {
                    ForEach(self.viewModel.viewState.rolls) { roll in
                        RollCardView(
                            rollCard: roll
                        ) {
                            self.viewModel.onRollTapped(roll.id)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                if let rollID = safeRollID(from: roll.id) {
                                    self.viewModel.onDeleteRoll(rollID)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .tint(.red)

                            Button {
                                if let rollID = safeRollID(from: roll.id) {
                                    self.viewModel.onEditRoll(rollID)
                                }
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.rcPink500)
                        }
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.95).combined(with: .opacity),
                            removal: .opacity
                        ))
                    }

                    if self.viewModel.viewState.hasMoreContent {
                        FeedLoadMoreButton(
                            isLoading: self.viewModel.viewState.isLoading,
                            onLoadMore: self.viewModel.onLoadMoreRequested
                        )
                    }
                }
                .padding(.horizontal, Spacing.Padding.medium)
                .padding(.vertical, Spacing.Padding.small)
            }
            .refreshable {
                self.viewModel.onRefreshRequested()
            }
        }

        private func errorView(message: String) -> some View {
            // Map error message back to AppError type for better context
            let appError: AppError = {
                if message.contains("network") || message.contains("connect") {
                    .networkError
                } else if message.contains("sign in") || message.contains("authentication") {
                    .authenticationError
                } else if message.contains("not found") || message.contains("not available") {
                    .dataNotFound
                } else if message.contains("server") {
                    .serverError
                } else {
                    .unknown
                }
            }()

            return ErrorView(
                error: appError
            ) {
                self.viewModel.onRefreshRequested()
            }
            .padding(Spacing.Padding.large)
        }

        // MARK: - Private Helper Methods

        private func safeRollID(from string: String) -> RollID? {
            guard let uuid = UUID(uuidString: string) else {
                print("⚠️ FeedView: Invalid UUID string: \(string)")
                return nil
            }
            return RollID(value: uuid)
        }
    }

    // MARK: - Preview

    #if DEBUG
        @available(iOS 15.0, *)
        struct FeedView_Previews: PreviewProvider {
            static var previews: some View {
                NavigationView {
                    FeedView(
                        viewModel: FeedViewModel(
                            rollRepository: InMemoryRollRepository(),
                            chefRepository: InMemoryChefRepository(),
                            restaurantRepository: InMemoryRestaurantRepository(),
                            hapticService: HapticFeedbackService()
                        )
                    )
                    .navigationTitle("Feed")
                    .navigationBarTitleDisplayMode(.large)
                }
            }
        }
    #endif

#endif
