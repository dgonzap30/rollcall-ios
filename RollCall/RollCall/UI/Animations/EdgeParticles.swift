//
// EdgeParticles.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/07/25.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
@MainActor
struct EdgeParticles: View {
    let isActive: Double
    @State private var animationPhase: Double = 0

    var body: some View {
        GeometryReader { geometry in
            // Subtle confetti animation on first load
            if self.isActive > 0.8 {
                ForEach(0..<12) { index in
                    ConfettiPiece(delay: Double(index) * 0.1)
                        .position(
                            x: CGFloat.random(in: geometry.size.width * 0.2...geometry.size.width * 0.8),
                            y: -20
                        )
                }
            }

            // Floating sakura petals - more subtle
            ForEach(0..<3) { _ in
                SakuraPetal()
                    .position(
                        x: CGFloat.random(in: 0...geometry.size.width),
                        y: -30
                    )
                    .opacity(0.4)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 10)
                    .repeatForever(autoreverses: false)
            ) {
                self.animationPhase = .pi * 2
            }
        }
    }
}

@available(iOS 15.0, macOS 12.0, *)
struct FloatingEdgeParticle: View {
    @State private var scale: CGFloat = .random(in: 0.8...1.2)
    private let isRice = Bool.random()

    var body: some View {
        Group {
            if self.isRice {
                // Rice grain shape
                Capsule()
                    .fill(Color.white.opacity(0.7))
                    .frame(width: 3, height: 6)
                    .rotationEffect(.degrees(Double.random(in: 0...360)))
            } else {
                // Sesame seed shape
                Circle()
                    .fill(Color.white.opacity(0.6))
                    .frame(width: 4, height: 4)
            }
        }
        .scaleEffect(self.scale)
        .onAppear {
            withAnimation(
                .easeInOut(duration: Double.random(in: 2...4))
                    .repeatForever(autoreverses: true)
            ) {
                self.scale *= CGFloat.random(in: 0.9...1.1)
            }
        }
    }
}
