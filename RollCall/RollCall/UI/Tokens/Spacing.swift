//
// Spacing.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

#if canImport(SwiftUI)
    import SwiftUI

    @available(iOS 15.0, *)
    public enum Spacing {
        public static let grid: CGFloat = 4

        public static let xxxSmall: CGFloat = 4
        public static let xxSmall: CGFloat = 8
        public static let xSmall: CGFloat = 12
        public static let small: CGFloat = 16
        public static let medium: CGFloat = 20
        public static let large: CGFloat = 24
        public static let xLarge: CGFloat = 28
        public static let xxLarge: CGFloat = 32
        public static let xxxLarge: CGFloat = 36
        public static let huge: CGFloat = 40
        public static let xHuge: CGFloat = 44
        public static let xxHuge: CGFloat = 48
        public static let xxxHuge: CGFloat = 52
        public static let massive: CGFloat = 56
        public static let xMassive: CGFloat = 60

        public enum Padding {
            public static let tiny: CGFloat = 4
            public static let small: CGFloat = 8
            public static let medium: CGFloat = 16
            public static let large: CGFloat = 24
            public static let xLarge: CGFloat = 32
            public static let xxLarge: CGFloat = 40
            public static let huge: CGFloat = 56
        }

        public enum Margin {
            public static let small: CGFloat = 8
            public static let medium: CGFloat = 16
            public static let large: CGFloat = 24
            public static let xLarge: CGFloat = 32
            public static let xxLarge: CGFloat = 48
        }

        public enum Gap {
            public static let tiny: CGFloat = 4
            public static let small: CGFloat = 8
            public static let medium: CGFloat = 12
            public static let large: CGFloat = 16
            public static let xLarge: CGFloat = 20
            public static let xxLarge: CGFloat = 24
        }

        public static func custom(_ multiplier: Int) -> CGFloat {
            CGFloat(multiplier) * self.grid
        }

        public static func isOnGrid(_ value: CGFloat) -> Bool {
            value.truncatingRemainder(dividingBy: self.grid) == 0
        }
    }

    @available(iOS 15.0, *)
    public extension View {
        @ViewBuilder
        func rcPadding(_ spacing: CGFloat, _ edges: Edge.Set = .all) -> some View {
            padding(edges, spacing)
        }

        // Note: For stack spacing, use .spacing() directly on VStack/HStack
        // Example: VStack(spacing: Spacing.medium) { ... }
    }
#endif
