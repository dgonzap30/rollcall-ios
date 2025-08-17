//
// Typography.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

#if canImport(SwiftUI)
    import SwiftUI

    @available(iOS 15.0, *)
    public enum Typography {
        public enum FontFamily {
            public static let headers = "Poppins-SemiBold"
            public static let headersRegular = "Poppins-Regular"
            public static let body = "Inter-Regular"
            public static let bodyMedium = "Inter-Medium"
            public static let bodySemiBold = "Inter-SemiBold"
            public static let bodyBold = "Inter-Bold"
        }

        public enum Size {
            public static let xxSmall: CGFloat = 11
            public static let xSmall: CGFloat = 12
            public static let small: CGFloat = 14
            public static let medium: CGFloat = 16
            public static let large: CGFloat = 18
            public static let xLarge: CGFloat = 20
            public static let xxLarge: CGFloat = 24
            public static let xxxLarge: CGFloat = 28
            public static let display: CGFloat = 32
            public static let displayLarge: CGFloat = 36
        }

        public enum LineHeight {
            public static let tight: CGFloat = 1.2
            public static let normal: CGFloat = 1.4
            public static let relaxed: CGFloat = 1.6
            public static let loose: CGFloat = 1.8
        }

        public enum Weight {
            public static let regular = Font.Weight.regular
            public static let medium = Font.Weight.medium
            public static let semiBold = Font.Weight.semibold
            public static let bold = Font.Weight.bold
        }

        public enum Style {
            public static func displayLarge() -> Font {
                Font.custom(FontFamily.headers, size: Size.displayLarge)
            }

            public static func display() -> Font {
                Font.custom(FontFamily.headers, size: Size.display)
            }

            public static func title1() -> Font {
                Font.custom(FontFamily.headers, size: Size.xxxLarge)
            }

            public static func title2() -> Font {
                Font.custom(FontFamily.headers, size: Size.xxLarge)
            }

            public static func title3() -> Font {
                Font.custom(FontFamily.headers, size: Size.xLarge)
            }

            public static func headline() -> Font {
                Font.custom(FontFamily.bodySemiBold, size: Size.large)
            }

            public static func body() -> Font {
                Font.custom(FontFamily.body, size: Size.medium)
            }

            public static func bodyMedium() -> Font {
                Font.custom(FontFamily.bodyMedium, size: Size.medium)
            }

            public static func bodySemiBold() -> Font {
                Font.custom(FontFamily.bodySemiBold, size: Size.medium)
            }

            public static func callout() -> Font {
                Font.custom(FontFamily.body, size: Size.small)
            }

            public static func caption() -> Font {
                Font.custom(FontFamily.body, size: Size.xSmall)
            }

            public static func footnote() -> Font {
                Font.custom(FontFamily.body, size: Size.xxSmall)
            }
        }
    }

    @available(iOS 15.0, *)
    public extension View {
        @ViewBuilder
        func rcFont(_ style: () -> Font) -> some View {
            font(style())
        }

        @ViewBuilder
        func rcLineHeight(_ multiplier: CGFloat) -> some View {
            // Line height multiplier - 1.0 means default, 1.5 means 150% line height
            // SwiftUI doesn't provide direct line height control, so we approximate
            // Default to 16pt (medium size) as base for line height calculation
            let baseSize: CGFloat = 16
            lineSpacing((baseSize * multiplier) - baseSize)
        }
    }

    // Convenient font extensions
    @available(iOS 15.0, *)
    public extension Font {
        static var rcDisplayLarge: Font { Typography.Style.displayLarge() }
        static var rcDisplay: Font { Typography.Style.display() }
        static var rcTitle1: Font { Typography.Style.title1() }
        static var rcTitle2: Font { Typography.Style.title2() }
        static var rcTitle3: Font { Typography.Style.title3() }
        static var rcHeadline: Font { Typography.Style.headline() }
        static var rcBody: Font { Typography.Style.body() }
        static var rcBodyMedium: Font { Typography.Style.bodyMedium() }
        static var rcBodySemiBold: Font { Typography.Style.bodySemiBold() }
        static var rcCallout: Font { Typography.Style.callout() }
        static var rcCaption: Font { Typography.Style.caption() }
        static var rcFootnote: Font { Typography.Style.footnote() }
    }
#endif
