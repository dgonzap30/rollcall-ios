//
// MainTabView.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import SwiftUI

@available(iOS 15.0, *)
@MainActor
struct MainTabView: View {
    @ObservedObject var viewModel: MainTabViewModel

    var body: some View {
        TabView(selection: Binding(
            get: { self.viewModel.viewState.selectedTab },
            set: { self.viewModel.onTabSelected($0) }
        )) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Group {
                    switch tab {
                    case .feed:
                        // Placeholder for Feed feature
                        VStack {
                            Text("Feed")
                                .font(.largeTitle)
                                .foregroundColor(.rcSeaweed800)
                            Text("Your sushi timeline")
                                .font(.body)
                                .foregroundColor(.rcSoy600)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.rcRice50)
                        .accessibilityLabel("Feed tab. Your sushi timeline")
                        .accessibilityHint("Double tap to view your feed")
                    case .create:
                        // Placeholder for Create Roll feature
                        VStack {
                            Image(systemName: "plus.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.rcPink500)
                                .accessibilityHidden(true)
                            Text("Create Roll")
                                .font(.largeTitle)
                                .foregroundColor(.rcSeaweed800)
                            Text("Log your sushi experience")
                                .font(.body)
                                .foregroundColor(.rcSoy600)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.rcRice50)
                        .accessibilityLabel("Create roll tab")
                        .accessibilityHint("Double tap to log a new sushi experience")
                        .onTapGesture {
                            self.viewModel.onCreateRollTapped()
                        }
                    case .profile:
                        // Placeholder for Profile feature
                        VStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 80))
                                .foregroundColor(.rcPink500)
                                .accessibilityHidden(true)
                            Text("Your Profile")
                                .font(.largeTitle)
                                .foregroundColor(.rcSeaweed800)
                            Text("Track your sushi journey")
                                .font(.body)
                                .foregroundColor(.rcSoy600)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.rcRice50)
                        .accessibilityLabel("Profile tab")
                        .accessibilityHint("Double tap to view your sushi journey")
                    }
                }
                .tabItem {
                    Label(tab.title, systemImage: tab.systemImage)
                }
                .tag(tab)
                .badge(self.badgeCount(for: tab))
            }
        }
        .accentColor(.rcPink500)
        .overlay(self.errorOverlay)
        .overlay(self.loadingOverlay)
    }

    private func badgeCount(for tab: Tab) -> Int {
        switch tab {
        case .feed:
            self.viewModel.viewState.feedBadgeCount
        case .profile:
            self.viewModel.viewState.profileBadgeCount
        case .create:
            0
        }
    }

    @ViewBuilder
    private var errorOverlay: some View {
        if let error = viewModel.viewState.error {
            VStack {
                Spacer()
                ErrorBanner(
                    message: error,
                    onDismiss: self.viewModel.dismissError
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            .animation(AnimationTokens.Curve.easeInOut, value: self.viewModel.viewState.error)
        }
    }

    @ViewBuilder
    private var loadingOverlay: some View {
        if self.viewModel.viewState.isLoading {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .overlay(
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .rcPink500))
                        .scaleEffect(1.5)
                )
                .transition(.opacity)
                .animation(AnimationTokens.Curve.standard(), value: self.viewModel.viewState.isLoading)
        }
    }
}

// MARK: - Error Banner

@available(iOS 15.0, *)
@MainActor
private struct ErrorBanner: View {
    let message: String
    let onDismiss: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.white)
                .accessibilityHidden(true)

            Text(self.message)
                .font(.body)
                .foregroundColor(.white)
                .lineLimit(2)
                .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: self.onDismiss) {
                Image(systemName: "xmark")
                    .foregroundColor(.white)
                    .padding(8)
                    .contentShape(Rectangle())
            }
            .accessibilityLabel("Dismiss error")
        }
        .padding()
        .background(Color.red)
        .cornerRadius(12)
        .padding()
        .shadow(radius: 4)
    }
}
