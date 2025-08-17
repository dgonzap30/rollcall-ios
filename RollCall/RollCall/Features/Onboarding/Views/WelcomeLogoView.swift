//
// WelcomeLogoView.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import SwiftUI

#if canImport(SwiftUI)
    @available(iOS 15.0, *)
    @MainActor
    public struct WelcomeLogoView: View {
        // Logo sizes - keeping as constants since they're specific to this component
        private static let logoPlateSize: CGFloat = 192
        private static let logoImageSize: CGFloat = 144

        let logoState: WelcomeViewState.LogoState
        let showParticles: Bool

        public init(logoState: WelcomeViewState.LogoState, showParticles: Bool) {
            self.logoState = logoState
            self.showParticles = showParticles
        }

        public var body: some View {
            ZStack {
                self.logoPlate
                    .scaleEffect(self.logoState.scale)
                    .opacity(self.logoState.opacity)

                Image("RollCallLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: Self.logoImageSize, height: Self.logoImageSize)
                    .scaleEffect(self.logoState.scale * self.logoState.pulseScale)
                    .opacity(self.logoState.opacity)
                    .rotationEffect(.degrees(self.logoState.rotation))
                    .offset(y: self.logoState.floatingOffset)
                    .compositingGroup()
                    .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 4)

                if self.showParticles {
                    ParticleSystem(isActive: self.showParticles)
                        .allowsHitTesting(false)
                }
            }
        }

        private var logoPlate: some View {
            Circle()
                .fill(Color.white)
                .frame(width: Self.logoPlateSize, height: Self.logoPlateSize)
                .overlay(
                    Circle()
                        .stroke(Color.rcNori800.opacity(0.08), lineWidth: 1)
                        .padding(1)
                )
                .compositingGroup()
                .rcNeumorphism()
        }
    }

    #if DEBUG
        @available(iOS 15.0, *)
        struct WelcomeLogoView_Previews: PreviewProvider {
            static var previews: some View {
                WelcomeLogoView(
                    logoState: WelcomeViewState.LogoState(
                        scale: 1.0,
                        opacity: 1.0,
                        rotation: 0,
                        floatingOffset: 0,
                        pulseScale: 1.0
                    ),
                    showParticles: true
                )
                .frame(width: 300, height: 300)
                .background(Color.rcRice50)
            }
        }
    #endif
#endif
