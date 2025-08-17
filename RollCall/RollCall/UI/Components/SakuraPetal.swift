//
// SakuraPetal.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/07/25.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
struct SakuraPetal: View {
    @State private var rotation: Double = 0
    @State private var offsetY: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    @State private var opacity: Double = 0

    private let startX = CGFloat.random(in: -20...20)
    private let duration = Double.random(in: 12...18)
    private let delay = Double.random(in: 0...5)

    var body: some View {
        PetalShape()
            .fill(
                LinearGradient(
                    colors: [
                        Color.rcPink500.opacity(0.15),
                        Color.rcPink100.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 20, height: 24)
            .rotationEffect(.degrees(self.rotation))
            .offset(x: self.startX + self.offsetX, y: self.offsetY)
            .opacity(self.opacity)
            .onAppear {
                withAnimation(
                    .easeIn(duration: self.duration)
                        .delay(self.delay)
                        .repeatForever(autoreverses: false)
                ) {
                    self.offsetY = 800 // Approximate screen height
                    self.offsetX = self.startX + CGFloat.random(in: -50...50)
                    self.rotation = 360 + Double.random(in: -180...180)
                }

                withAnimation(
                    .easeIn(duration: 1)
                        .delay(self.delay)
                ) {
                    self.opacity = 0.6
                }

                withAnimation(
                    .easeOut(duration: 2)
                        .delay(self.delay + self.duration - 2)
                ) {
                    self.opacity = 0
                }
            }
    }
}

@available(iOS 15.0, macOS 12.0, *)
struct PetalShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        // Sakura petal shape
        path.move(to: CGPoint(x: width * 0.5, y: 0))

        path.addCurve(
            to: CGPoint(x: width * 0.9, y: height * 0.7),
            control1: CGPoint(x: width * 0.8, y: height * 0.2),
            control2: CGPoint(x: width * 0.95, y: height * 0.5)
        )

        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height),
            control1: CGPoint(x: width * 0.8, y: height * 0.9),
            control2: CGPoint(x: width * 0.6, y: height * 0.95)
        )

        path.addCurve(
            to: CGPoint(x: width * 0.1, y: height * 0.7),
            control1: CGPoint(x: width * 0.4, y: height * 0.95),
            control2: CGPoint(x: width * 0.2, y: height * 0.9)
        )

        path.addCurve(
            to: CGPoint(x: width * 0.5, y: 0),
            control1: CGPoint(x: width * 0.05, y: height * 0.5),
            control2: CGPoint(x: width * 0.2, y: height * 0.2)
        )

        path.closeSubpath()

        return path
    }
}
