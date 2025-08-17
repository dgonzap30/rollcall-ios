//
// Shadow.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

#if canImport(SwiftUI)
    import SwiftUI

    @available(iOS 15.0, *)
    public enum Shadow {
        public struct Style {
            let color: Color
            let radius: CGFloat
            let xOffset: CGFloat
            let yOffset: CGFloat

            public init(color: Color, radius: CGFloat, x xOffset: CGFloat = 0, y yOffset: CGFloat = 0) {
                self.color = color
                self.radius = radius
                self.xOffset = xOffset
                self.yOffset = yOffset
            }
        }

        public enum Elevation {
            public static let none = Style(
                color: .clear,
                radius: 0
            )

            public static let small = Style(
                color: Color.rcSeaweed900.opacity(0.08),
                radius: 4,
                y: 2
            )

            public static let medium = Style(
                color: Color.rcSeaweed900.opacity(0.10),
                radius: 8,
                y: 4
            )

            public static let large = Style(
                color: Color.rcSeaweed900.opacity(0.12),
                radius: 16,
                y: 8
            )

            public static let cta = Style(
                color: Color.rcSeaweed900.opacity(0.15),
                radius: 12,
                y: 3
            )

            public static let card = Style(
                color: Color.rcSeaweed900.opacity(0.10),
                radius: 24,
                y: 8
            )
        }

        public enum Neumorphism {
            public static func light() -> (top: Style, bottom: Style) {
                (
                    top: Style(
                        color: Color.white.opacity(0.6),
                        radius: 10,
                        x: -5,
                        y: -5
                    ),
                    bottom: Style(
                        color: Color.rcPink100.opacity(0.5),
                        radius: 10,
                        x: 5,
                        y: 5
                    )
                )
            }

            public static func medium() -> (top: Style, bottom: Style) {
                (
                    top: Style(
                        color: Color.white.opacity(0.7),
                        radius: 15,
                        x: -8,
                        y: -8
                    ),
                    bottom: Style(
                        color: Color.rcPink100.opacity(0.6),
                        radius: 15,
                        x: 8,
                        y: 8
                    )
                )
            }
        }

        public enum Inner {
            public static let subtle = Style(
                color: Color.rcSeaweed900.opacity(0.08),
                radius: 2
            )

            public static let medium = Style(
                color: Color.rcSeaweed900.opacity(0.12),
                radius: 4
            )
        }
    }

    @available(iOS 15.0, *)
    public extension View {
        @ViewBuilder
        func rcShadow(_ style: Shadow.Style) -> some View {
            shadow(
                color: style.color,
                radius: style.radius,
                x: style.xOffset,
                y: style.yOffset
            )
        }

        @ViewBuilder
        func rcNeumorphism() -> some View {
            let styles = Shadow.Neumorphism.light()
            self.rcShadow(styles.top)
                .rcShadow(styles.bottom)
        }

        @ViewBuilder
        func rcCTAShadow() -> some View {
            self.rcShadow(Shadow.Elevation.cta)
                .overlay(
                    RoundedRectangle(cornerRadius: BorderRadius.medium)
                        .stroke(Color.white.opacity(0.3), lineWidth: StrokeWidth.standard)
                        .blendMode(.overlay)
                )
        }
    }
#endif
