//
// FeedStateViews.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

#if canImport(SwiftUI)
    import SwiftUI

    // MARK: - Loading View

    @available(iOS 15.0, *)
    public struct FeedLoadingView: View {
        public init() {}

        public var body: some View {
            VStack(spacing: Spacing.large) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .rcPink500))
                    .scaleEffect(1.5)

                Text("Loading delicious rolls...")
                    .font(.rcBody)
                    .foregroundColor(.rcSeaweed800)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Loading feed content")
        }
    }

    // MARK: - Empty State View

    @available(iOS 15.0, *)
    public struct FeedEmptyStateView: View {
        let message: String?
        let onCreateRollTapped: () -> Void

        public init(message: String?, onCreateRollTapped: @escaping () -> Void) {
            self.message = message
            self.onCreateRollTapped = onCreateRollTapped
        }

        public var body: some View {
            VStack(spacing: Spacing.xxLarge) {
                SushiIcon(type: .maki)
                    .scaleEffect(3.3)
                    .foregroundColor(.rcPink500.opacity(0.6))

                VStack(spacing: Spacing.small) {
                    Text("No rolls yet!")
                        .font(.rcHeadline)
                        .foregroundColor(.rcSeaweed800)

                    if let message {
                        Text(message)
                            .font(.rcBody)
                            .foregroundColor(.rcSoy600)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, Spacing.Padding.large)
                    }
                }

                GradientCTAButton(
                    title: "Create Your First Roll",
                    systemIcon: "plus.circle.fill",
                    action: self.onCreateRollTapped
                )
                .padding(.horizontal, Spacing.Padding.xLarge)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Empty feed. Create your first roll")
        }
    }

    // MARK: - Load More Button

    @available(iOS 15.0, *)
    public struct FeedLoadMoreButton: View {
        let isLoading: Bool
        let onLoadMore: () -> Void

        public init(isLoading: Bool, onLoadMore: @escaping () -> Void) {
            self.isLoading = isLoading
            self.onLoadMore = onLoadMore
        }

        public var body: some View {
            Button(action: self.onLoadMore) {
                HStack(spacing: Spacing.small) {
                    if self.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .rcPink500))
                            .scaleEffect(0.8)
                    } else {
                        Text("Load More")
                            .font(.rcBody)
                            .fontWeight(.medium)
                    }
                }
                .foregroundColor(.rcPink500)
                .padding(.vertical, Spacing.Padding.small)
                .padding(.horizontal, Spacing.Padding.medium)
                .background(Color.rcRice75)
                .cornerRadius(BorderRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: BorderRadius.medium)
                        .strokeBorder(Color.rcNori800.opacity(0.08), lineWidth: 1)
                )
            }
            .padding(.vertical, Spacing.medium)
            .accessibilityLabel("Load more rolls")
            .accessibilityHint("Double tap to load additional content")
        }
    }

#endif
