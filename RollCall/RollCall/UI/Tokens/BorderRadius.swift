//
// BorderRadius.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

#if canImport(SwiftUI)
    import SwiftUI

    @available(iOS 15.0, *)
    public enum BorderRadius {
        public static let none: CGFloat = 0
        public static let xSmall: CGFloat = 4
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 12
        public static let large: CGFloat = 16
        public static let xLarge: CGFloat = 20
        public static let xxLarge: CGFloat = 24
        public static let full: CGFloat = 9999

        public enum Component {
            public static let badge: CGFloat = 4
            public static let button: CGFloat = 12
            public static let textField: CGFloat = 12
            public static let card: CGFloat = 16
            public static let modal: CGFloat = 20
            public static let container: CGFloat = 24
        }
    }

    /// Corner selection for partial corner radius
    public struct RCRectCorner: OptionSet {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let topLeft = Self(rawValue: 1 << 0)
        public static let topRight = Self(rawValue: 1 << 1)
        public static let bottomLeft = Self(rawValue: 1 << 2)
        public static let bottomRight = Self(rawValue: 1 << 3)

        public static let top: RCRectCorner = [.topLeft, .topRight]
        public static let bottom: RCRectCorner = [.bottomLeft, .bottomRight]
        public static let left: RCRectCorner = [.topLeft, .bottomLeft]
        public static let right: RCRectCorner = [.topRight, .bottomRight]
        public static let all: RCRectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
    }

    @available(iOS 15.0, *)
    public extension View {
        @ViewBuilder
        func rcCornerRadius(_ radius: CGFloat) -> some View {
            clipShape(RoundedRectangle(cornerRadius: radius))
        }

        @ViewBuilder
        func rcCornerRadius(_ radius: CGFloat, corners: RCRectCorner) -> some View {
            if #available(iOS 16.0, *) {
                self.clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: corners.contains(.topLeft) ? radius : 0,
                        bottomLeadingRadius: corners.contains(.bottomLeft) ? radius : 0,
                        bottomTrailingRadius: corners.contains(.bottomRight) ? radius : 0,
                        topTrailingRadius: corners.contains(.topRight) ? radius : 0
                    )
                )
            } else {
                // Fallback for iOS 15: Use regular rounded corners
                // Note: This applies to all corners, not selective ones
                clipShape(RoundedRectangle(cornerRadius: radius))
            }
        }
    }

    @available(iOS 15.0, *)
    public extension RoundedRectangle {
        static func rc(_ radius: CGFloat) -> RoundedRectangle {
            RoundedRectangle(cornerRadius: radius)
        }
    }
#endif
