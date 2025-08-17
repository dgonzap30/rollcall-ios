//
// SushiIcon.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/07/25.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
struct SushiIcon: View {
    enum SushiType {
        case nigiri
        case maki
    }

    let type: SushiType
    @State private var isAnimating = false

    var body: some View {
        Group {
            switch self.type {
            case .nigiri:
                self.nigiriIcon
            case .maki:
                self.makiIcon
            }
        }
        .frame(width: 24, height: 24)
        .rotationEffect(.degrees(self.isAnimating ? 5 : -5))
        .onAppear {
            withAnimation(
                .easeInOut(duration: 3)
                    .repeatForever(autoreverses: true)
            ) {
                self.isAnimating = true
            }
        }
    }

    private var nigiriIcon: some View {
        VStack(spacing: 2) {
            // Fish
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.rcSalmon300.opacity(0.8))
                .frame(width: 20, height: 8)
                .overlay(
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 1, height: 8)
                        .offset(x: -4)
                )

            // Rice
            Ellipse()
                .fill(Color.white)
                .frame(width: 18, height: 10)
                .overlay(
                    Ellipse()
                        .stroke(Color.rcSeaweed800.opacity(0.1), lineWidth: 0.5)
                )
        }
    }

    private var makiIcon: some View {
        ZStack {
            // Nori wrapper
            Circle()
                .fill(Color.rcSeaweed800.opacity(0.8))
                .frame(width: 22, height: 22)

            // Rice ring
            Circle()
                .fill(Color.white)
                .frame(width: 18, height: 18)

            // Center filling
            Circle()
                .fill(Color.rcSalmon300.opacity(0.9))
                .frame(width: 8, height: 8)
        }
    }
}
