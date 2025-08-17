//
// BrushStrokeShape.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/07/25.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, *)
struct BrushStrokeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height

        // Artistic brush stroke with varying thickness
        path.move(to: CGPoint(x: width * 0.05, y: height * 0.6))

        // Left edge with taper
        path.addCurve(
            to: CGPoint(x: width * 0.15, y: height * 0.4),
            control1: CGPoint(x: width * 0.08, y: height * 0.55),
            control2: CGPoint(x: width * 0.12, y: height * 0.45)
        )

        // Top edge with organic variation
        path.addCurve(
            to: CGPoint(x: width * 0.85, y: height * 0.35),
            control1: CGPoint(x: width * 0.4, y: height * 0.3),
            control2: CGPoint(x: width * 0.6, y: height * 0.4)
        )

        // Right edge with flourish
        path.addCurve(
            to: CGPoint(x: width * 0.95, y: height * 0.5),
            control1: CGPoint(x: width * 0.9, y: height * 0.38),
            control2: CGPoint(x: width * 0.93, y: height * 0.45)
        )

        // Bottom edge back
        path.addCurve(
            to: CGPoint(x: width * 0.85, y: height * 0.65),
            control1: CGPoint(x: width * 0.92, y: height * 0.55),
            control2: CGPoint(x: width * 0.88, y: height * 0.6)
        )

        path.addCurve(
            to: CGPoint(x: width * 0.15, y: height * 0.7),
            control1: CGPoint(x: width * 0.6, y: height * 0.7),
            control2: CGPoint(x: width * 0.4, y: height * 0.65)
        )

        // Close back to start
        path.addCurve(
            to: CGPoint(x: width * 0.05, y: height * 0.6),
            control1: CGPoint(x: width * 0.1, y: height * 0.68),
            control2: CGPoint(x: width * 0.07, y: height * 0.63)
        )

        path.closeSubpath()

        return path
    }
}
