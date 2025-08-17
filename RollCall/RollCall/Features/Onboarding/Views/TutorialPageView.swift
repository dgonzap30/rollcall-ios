//
// TutorialPageView.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import SwiftUI

struct TutorialPageView: View {
    let page: OnboardingPage
    let onButtonTapped: () -> Void

    @State private var illustrationScale: CGFloat = 0.8
    @State private var illustrationOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var buttonScale: CGFloat = 0.9

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            self.illustrationView
                .frame(height: OnboardingConstants.Layout.illustrationHeight)
                .scaleEffect(self.illustrationScale)
                .opacity(self.illustrationOpacity)

            VStack(spacing: OnboardingConstants.Layout.verticalSpacing) {
                self.textContent
                    .opacity(self.contentOpacity)

                if let buttonTitle = page.buttonTitle {
                    self.actionButton(title: buttonTitle)
                        .scaleEffect(self.buttonScale)
                        .opacity(self.contentOpacity)
                }
            }
            .padding(.top, OnboardingConstants.Layout.verticalSpacing)

            Spacer()
        }
        .padding(.horizontal, OnboardingConstants.Layout.horizontalPadding)
        .onAppear {
            self.animateIn()
        }
    }

    private var illustrationView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.rcRice50)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.rcSeaweed800.opacity(0.1), lineWidth: 1)
                )

            VStack(spacing: 16) {
                Image(systemName: self.illustrationIcon)
                    .font(.system(size: 60))
                    .foregroundColor(.rcPink500)

                Text(self.illustrationText)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.rcSeaweed800.opacity(0.6))
            }
        }
    }

    private var illustrationIcon: String {
        switch self.page.id {
        case 1: "book.fill"
        case 2: "sparkles"
        default: "questionmark"
        }
    }

    private var illustrationText: String {
        switch self.page.id {
        case 1: "Track & Rate"
        case 2: "Discover & Share"
        default: ""
        }
    }

    private var textContent: some View {
        VStack(spacing: 16) {
            Text(self.page.title)
                .font(.system(size: OnboardingConstants.Typography.titleSize, weight: .bold))
                .foregroundColor(.rcSeaweed800)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text(self.page.subtitle)
                .font(.system(size: OnboardingConstants.Typography.subtitleSize))
                .foregroundColor(.rcSeaweed800.opacity(0.7))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 20)
        }
    }

    private func actionButton(title: String) -> some View {
        Button(action: {
            withAnimation(.easeOut(duration: OnboardingConstants.Animation.buttonPressDuration)) {
                self.buttonScale = 0.95
            }

            Task {
                try? await Task
                    .sleep(nanoseconds: UInt64(OnboardingConstants.Animation.buttonPressDuration * 1_000_000_000))
                withAnimation(.easeOut(duration: OnboardingConstants.Animation.buttonPressDuration)) {
                    self.buttonScale = 1.0
                }
                self.onButtonTapped()
            }
        }, label: {
            ZStack {
                LinearGradient(
                    colors: [Color.rcGradientPink, Color.rcGradientOrange],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                        .padding(1)
                )

                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.white)
            }
            .frame(height: OnboardingConstants.Layout.buttonHeight)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 3)
        })
        .accessibilityLabel(title)
        .accessibilityHint("Double tap to continue")
    }

    private func animateIn() {
        withAnimation(.easeOut(duration: OnboardingConstants.Animation.fadeInDuration)) {
            self.illustrationScale = 1.0
            self.illustrationOpacity = 1.0
        }

        withAnimation(.easeOut(duration: OnboardingConstants.Animation.fadeInDuration).delay(0.1)) {
            self.contentOpacity = 1.0
            self.buttonScale = 1.0
        }
    }
}
