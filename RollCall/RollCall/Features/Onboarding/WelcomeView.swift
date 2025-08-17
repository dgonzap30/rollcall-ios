//
// WelcomeView.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import SwiftUI

@available(iOS 15.0, *)
@MainActor
public struct WelcomeView: View {
    // Using design tokens directly

    @ObservedObject var viewModel: WelcomeViewModel

    public init(viewModel: WelcomeViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: Spacing.xMassive)
            self.logoSection.padding(.bottom, Spacing.huge)
            self.contentSection.padding(.bottom, Spacing.xxLarge)
            self.buttonSection
                .padding(.horizontal, Spacing.huge)
                .padding(.bottom, Spacing.xxLarge)
            self.decorativeText.padding(.bottom, Spacing.medium)
            Spacer(minLength: Spacing.huge)
        }
        .background(Color.rcRice50)
        .onAppear {
            self.viewModel.startAnimations()
        }
        .onDisappear {
            self.viewModel.stopAnimations()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Welcome to RollCall")
    }

    private var logoSection: some View {
        WelcomeLogoView(
            logoState: self.viewModel.viewState.logo,
            showParticles: self.viewModel.viewState.showParticles
        )
        .animation(AnimationTokens.Spring.gentle(), value: self.viewModel.viewState.logo)
    }

    private var contentSection: some View {
        VStack(spacing: 0) {
            Text("RollCall")
                .font(.system(size: 64, weight: .black, design: .rounded))
                .foregroundColor(Color.rcPink500)
                .shadow(color: Color.black.opacity(0.08), radius: 2, x: 0, y: 2)
                .opacity(self.viewModel.viewState.content.titleOpacity)
                .padding(.bottom, Spacing.large)
                .accessibilityAddTraits(.isHeader)

            Text("Your personal sushi journal")
                .font(.system(size: Typography.Size.xLarge, weight: .semibold, design: .rounded))
                .foregroundColor(Color.rcSeaweed800)
                .opacity(self.viewModel.viewState.content.subtitleOpacity)
                .padding(.bottom, Spacing.small)
                .accessibilityLabel("Your personal sushi journal")

            Text("TRACK • RATE • REMEMBER")
                .font(.system(size: Typography.Size.xSmall, weight: .medium, design: .rounded))
                .foregroundColor(Color.rcSoy600)
                .kerning(2.6)
                .textCase(.uppercase)
                .opacity(self.viewModel.viewState.content.taglineOpacity)
                .accessibilityLabel("Track, Rate, Remember")
        }
        .animation(AnimationTokens.Curve.standardSlow(), value: self.viewModel.viewState.content)
        .accessibilityElement(children: .combine)
    }

    private var buttonSection: some View {
        HStack(spacing: Spacing.xSmall) {
            SushiLineIcon()
                .stroke(Color.white, lineWidth: StrokeWidth.standard)
                .frame(width: IconSize.medium, height: IconSize.medium)

            Text("Begin Your Journey")
                .font(Typography.Style.headline())
                .foregroundColor(.white)
                .kerning(0.3)

            Image(systemName: "arrow.right")
                .font(.system(size: Typography.Size.small, weight: .semibold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, Spacing.large)
        .frame(maxWidth: .infinity)
        .frame(height: ButtonSize.largeHeight)
        .background(
            RoundedRectangle(cornerRadius: BorderRadius.medium)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.rcGradientPink,
                            Color.rcGradientOrange
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: BorderRadius.medium)
                        .stroke(Color.white.opacity(0.3), lineWidth: StrokeWidth.thin)
                        .padding(1)
                )
        )
        .scaleEffect(self.viewModel.viewState.button.isPressed ? 0.95 : self.viewModel.viewState.button.scale)
        .opacity(self.viewModel.viewState.button.opacity)
        .compositingGroup()
        .rcCTAShadow()
        .onTapGesture {
            Task { [weak viewModel] in
                await viewModel?.handleButtonPress()
            }
        }
        .animation(AnimationTokens.Spring.standard(), value: self.viewModel.viewState.button)
        .accessibilityLabel("Begin Your Journey")
        .accessibilityHint("Double tap to start using RollCall")
    }

    private var decorativeText: some View {
        Text("Itadakimasu!")
            .font(.system(size: Typography.Size.xSmall, weight: .medium, design: .rounded))
            .foregroundColor(Color.rcSoy600.opacity(0.6))
            .italic()
            .opacity(self.viewModel.viewState.content.taglineOpacity)
            .animation(
                AnimationTokens.Curve.easeOut.delay(AnimationTokens.Delay.long),
                value: self.viewModel.viewState.content.taglineOpacity
            )
    }
}

#if DEBUG
    @available(iOS 15.0, *)
    struct WelcomeView_Previews: PreviewProvider {
        static var previews: some View {
            WelcomeView(
                viewModel: WelcomeViewModel(
                    hapticService: NoOpHapticFeedbackService(),
                    accessibilityService: NoOpAccessibilityService()
                )
            )
        }
    }
#endif
