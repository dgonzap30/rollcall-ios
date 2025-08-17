//
// Animation.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

#if canImport(SwiftUI)
    import SwiftUI

    @available(iOS 15.0, *)
    public enum AnimationTokens {
        public enum Duration {
            public static let instant: Double = 0.1
            public static let fast: Double = 0.15
            public static let standard: Double = 0.2
            public static let medium: Double = 0.3
            public static let slow: Double = 0.4
            public static let celebratory: Double = 0.4
            public static let xSlow: Double = 0.6
        }

        public enum Curve {
            public static let easeInOut = Animation.easeInOut(duration: Duration.standard)
            public static let easeIn = Animation.easeIn(duration: Duration.standard)
            public static let easeOut = Animation.easeOut(duration: Duration.standard)
            public static let linear = Animation.linear(duration: Duration.standard)

            public static func standard() -> Animation {
                Animation.timingCurve(0.4, 0, 0.2, 1, duration: Duration.standard)
            }

            public static func standardSlow() -> Animation {
                Animation.timingCurve(0.4, 0, 0.2, 1, duration: Duration.slow)
            }
        }

        public enum Spring {
            public static func standard() -> Animation {
                Animation.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)
            }

            public static func bouncy() -> Animation {
                Animation.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)
            }

            public static func gentle() -> Animation {
                Animation.spring(response: 0.5, dampingFraction: 0.9, blendDuration: 0)
            }

            public static func celebratory() -> Animation {
                Animation.spring(response: 0.4, dampingFraction: 0.8, blendDuration: 0)
            }
        }

        public enum Delay {
            public static let none: Double = 0
            public static let short: Double = 0.05
            public static let medium: Double = 0.1
            public static let long: Double = 0.2
            public static let xLong: Double = 0.3
        }
    }

    @available(iOS 15.0, *)
    public extension View {
        @ViewBuilder
        func rcAnimation(_ animation: Animation? = AnimationTokens.Curve.standard()) -> some View {
            self.animation(animation, value: UUID())
        }

        @ViewBuilder
        func rcTransition(
            _ transition: AnyTransition = .opacity,
            animation: Animation = AnimationTokens.Curve.standard()
        ) -> some View {
            self.transition(transition.animation(animation))
        }
    }

    @available(iOS 15.0, *)
    public extension Animation {
        static var rcStandard: Animation {
            AnimationTokens.Curve.standard()
        }

        static var rcSpring: Animation {
            AnimationTokens.Spring.standard()
        }

        static var rcCelebratory: Animation {
            AnimationTokens.Spring.celebratory()
        }
    }
#endif
