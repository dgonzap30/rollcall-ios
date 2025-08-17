//
// RippleModifier.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/07/25.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
struct RippleModifier: ViewModifier {
    @State private var rippleScale: CGFloat = 0
    @State private var rippleOpacity: Double = 0
    let onTap: () -> Void

    func body(content: Content) -> some View {
        content
            .overlay(
                Circle()
                    .fill(Color.white.opacity(self.rippleOpacity))
                    .scaleEffect(self.rippleScale)
                    .allowsHitTesting(false)
            )
            .onTapGesture {
                // Trigger ripple animation
                withAnimation(.easeOut(duration: WelcomeConstants.Animation.rippleDuration)) {
                    self.rippleScale = 3
                    self.rippleOpacity = 0.3
                }

                withAnimation(.easeOut(duration: WelcomeConstants.Animation.rippleDuration).delay(0.1)) {
                    self.rippleOpacity = 0
                }

                // Reset using structured concurrency
                Task {
                    try? await Task
                        .sleep(nanoseconds: UInt64(WelcomeConstants.Animation.rippleDuration * 1_000_000_000) +
                            100_000_000
                        )
                    await MainActor.run {
                        self.rippleScale = 0
                    }
                }

                self.onTap()
            }
    }
}

@available(iOS 15.0, macOS 12.0, *)
extension View {
    func rippleEffect(onTap: @escaping () -> Void) -> some View {
        modifier(RippleModifier(onTap: onTap))
    }
}
