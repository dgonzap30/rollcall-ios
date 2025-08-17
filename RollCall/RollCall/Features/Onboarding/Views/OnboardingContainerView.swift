//
// OnboardingContainerView.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import SwiftUI

public struct OnboardingContainerView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    private let welcomeViewModel: WelcomeViewModel

    init(viewModel: OnboardingViewModel, welcomeViewModel: WelcomeViewModel) {
        self.viewModel = viewModel
        self.welcomeViewModel = welcomeViewModel
    }

    public var body: some View {
        ZStack {
            // Unified background for all onboarding screens
            self.backgroundView

            VStack(spacing: 0) {
                if self.viewModel.viewState.isSkipVisible || self.viewModel.selection == 0 {
                    self.skipButton
                        .padding(.horizontal, OnboardingConstants.Layout.skipButtonPadding)
                        .padding(.top, 8)
                }

                TabView(selection: self.$viewModel.selection) {
                    WelcomeView(viewModel: self.welcomeViewModel)
                        .tag(0)

                    ForEach(1..<self.viewModel.viewState.pages.count, id: \.self) { index in
                        if let page = viewModel.viewState.pages[safe: index] {
                            TutorialPageView(
                                page: page
                            ) {
                                if index == self.viewModel.viewState.pages.count - 1 {
                                    self.viewModel.onGetStartedTapped()
                                } else {
                                    self.viewModel.onNextTapped()
                                }
                            }
                            .tag(index)
                        }
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .onChange(of: self.viewModel.selection) { newValue in
                    self.viewModel.onPageChanged(to: newValue)
                }

                self.pageIndicators
                    .padding(.bottom, Spacing.xxHuge)
            }
        }
    }

    private var skipButton: some View {
        HStack {
            Spacer()

            Button(action: {
                self.viewModel.onSkipTapped()
            }, label: {
                Text("Skip")
                    .font(.system(size: OnboardingConstants.Typography.skipButtonSize))
                    .foregroundColor(.rcSeaweed800.opacity(0.7))
            })
            .accessibilityLabel("Skip onboarding")
            .accessibilityHint("Double tap to skip the remaining onboarding screens")
        }
    }

    private var pageIndicators: some View {
        HStack(spacing: OnboardingConstants.Layout.pageIndicatorSpacing) {
            ForEach(0..<self.viewModel.viewState.pages.count, id: \.self) { index in
                Circle()
                    .fill(self.viewModel.selection == index ? Color.rcPink500 : Color.rcSoy600.opacity(0.3))
                    .frame(
                        width: OnboardingConstants.Layout.pageIndicatorSize,
                        height: OnboardingConstants.Layout.pageIndicatorSize
                    )
                    .animation(OnboardingConstants.Animation.standardCurve, value: self.viewModel.selection)
                    .accessibilityLabel("Page \(index + 1) of \(self.viewModel.viewState.pages.count)")
                    .accessibilityHint(self.viewModel
                        .selection == index ? "Current page" : "Swipe to navigate to this page"
                    )
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var backgroundView: some View {
        ZStack {
            // Base with radial gradient
            RadialGradient(
                colors: [
                    Color.rcBackgroundCenter,
                    Color.rcBackgroundBase,
                    Color.rcBackgroundEdge
                ],
                center: .center,
                startRadius: 0,
                endRadius: 500
            )
            .ignoresSafeArea()

            // Decorative framing elements
            VStack {
                // Top wave decoration
                WaveShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.rcPink500.opacity(0.08),
                                Color.rcSalmon300.opacity(0.05)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 80)
                    .ignoresSafeArea(edges: .top)

                Spacer()

                // Bottom mat decoration
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.rcSeaweed800.opacity(0.03),
                                Color.clear
                            ],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .frame(height: 60)
                    .ignoresSafeArea(edges: .bottom)
            }

            // Bottom gradient overlay
            VStack {
                Spacer()
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.rcBottomGradient.opacity(0.3)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 150)
                .ignoresSafeArea(edges: .bottom)
            }

            // Edge accent particles
            EdgeParticles(isActive: 0.8)
        }
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
