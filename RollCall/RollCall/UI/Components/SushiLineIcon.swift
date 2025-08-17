//
// SushiLineIcon.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/07/25.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
struct SushiLineIcon: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        // Simplified sushi roll outline
        let rollWidth = width * 0.7
        let rollHeight = height * 0.5
        let centerX = width / 2
        let centerY = height / 2

        // Outer roll circle
        path.addEllipse(in: CGRect(
            x: centerX - rollWidth / 2,
            y: centerY - rollHeight / 2,
            width: rollWidth,
            height: rollHeight
        ))

        // Inner rice circle
        let riceSize = rollWidth * 0.6
        path.move(to: CGPoint(x: centerX, y: centerY - riceSize / 2))
        path.addArc(
            center: CGPoint(x: centerX, y: centerY),
            radius: riceSize / 2,
            startAngle: .degrees(-90),
            endAngle: .degrees(270),
            clockwise: false
        )

        // Center dot (fish)
        path.move(to: CGPoint(x: centerX + 2, y: centerY))
        path.addArc(
            center: CGPoint(x: centerX, y: centerY),
            radius: 2,
            startAngle: .degrees(0),
            endAngle: .degrees(360),
            clockwise: false
        )

        // Chopsticks
        let stickLength = width * 0.5
        let stickOffset = height * 0.15

        // First chopstick
        path.move(to: CGPoint(x: width - stickLength, y: stickOffset))
        path.addLine(to: CGPoint(x: width, y: stickOffset + 2))

        // Second chopstick
        path.move(to: CGPoint(x: width - stickLength, y: height - stickOffset))
        path.addLine(to: CGPoint(x: width, y: height - stickOffset - 2))

        return path
    }
}
