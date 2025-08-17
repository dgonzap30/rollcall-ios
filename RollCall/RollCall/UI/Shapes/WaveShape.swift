//
// WaveShape.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/07/25.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
struct WaveShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        path.move(to: CGPoint.zero)
        path.addLine(to: CGPoint(x: 0, y: height * 0.7))

        // Create wave pattern
        path.addCurve(
            to: CGPoint(x: width * 0.25, y: height * 0.85),
            control1: CGPoint(x: width * 0.08, y: height * 0.7),
            control2: CGPoint(x: width * 0.17, y: height * 0.85)
        )

        path.addCurve(
            to: CGPoint(x: width * 0.5, y: height * 0.75),
            control1: CGPoint(x: width * 0.33, y: height * 0.85),
            control2: CGPoint(x: width * 0.42, y: height * 0.75)
        )

        path.addCurve(
            to: CGPoint(x: width * 0.75, y: height * 0.9),
            control1: CGPoint(x: width * 0.58, y: height * 0.75),
            control2: CGPoint(x: width * 0.67, y: height * 0.9)
        )

        path.addCurve(
            to: CGPoint(x: width, y: height * 0.8),
            control1: CGPoint(x: width * 0.83, y: height * 0.9),
            control2: CGPoint(x: width * 0.92, y: height * 0.8)
        )

        path.addLine(to: CGPoint(x: width, y: 0))
        path.closeSubpath()

        return path
    }
}
