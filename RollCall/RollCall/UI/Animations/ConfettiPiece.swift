//
// ConfettiPiece.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/07/25.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
struct ConfettiPiece: View {
    let delay: Double
    @State private var offsetY: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0

    private let colors: [Color] = [
        .rcPink500.opacity(0.6),
        .rcSalmon300.opacity(0.6),
        .rcWasabi400.opacity(0.5),
        .rcGinger200.opacity(0.6)
    ]

    var body: some View {
        Rectangle()
            .fill(self.colors.randomElement() ?? .rcPink500)
            .frame(width: 8, height: 4)
            .rotationEffect(.degrees(self.rotation))
            .offset(x: self.offsetX, y: self.offsetY)
            .opacity(self.opacity)
            .onAppear {
                withAnimation(
                    .easeOut(duration: 2.5)
                        .delay(self.delay)
                ) {
                    self.offsetY = 600
                    self.offsetX = CGFloat.random(in: -100...100)
                    self.rotation = Double.random(in: 0...720)
                }

                withAnimation(
                    .easeIn(duration: 0.3)
                        .delay(self.delay)
                ) {
                    self.opacity = 0.8
                }

                withAnimation(
                    .easeOut(duration: 0.5)
                        .delay(self.delay + 2.0)
                ) {
                    self.opacity = 0
                }
            }
    }
}
