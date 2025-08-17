//
// DesignTokens.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

#if canImport(SwiftUI)
    import SwiftUI

    // MARK: - Design Tokens

    /// Central design token namespace for consistent design system values
    @available(iOS 15.0, *)
    public enum DesignTokens {
        public typealias Colors = Color
        public typealias Fonts = Typography
        public typealias Spacings = Spacing
        public typealias Animations = AnimationTokens
        public typealias Shadows = Shadow
        public typealias Radii = BorderRadius
    }

    // MARK: - Stroke Tokens

    /// Stroke width values for consistent borders and lines
    @available(iOS 15.0, *)
    public enum StrokeWidth {
        public static let thin: CGFloat = 1
        public static let standard: CGFloat = 2
        public static let thick: CGFloat = 3

        /// Icon-specific stroke width
        public static let icon: CGFloat = 2
    }

    // MARK: - Size Tokens

    /// Icon size values following the design system
    @available(iOS 15.0, *)
    public enum IconSize {
        public static let small: CGFloat = 16
        public static let medium: CGFloat = 20
        public static let standard: CGFloat = 24
        public static let large: CGFloat = 32
        public static let xLarge: CGFloat = 40
    }

    /// Button height values for consistent CTAs
    @available(iOS 15.0, *)
    public enum ButtonSize {
        public static let minHeight: CGFloat = 44
        public static let standardHeight: CGFloat = 48
        public static let largeHeight: CGFloat = 56
    }

    /// Avatar size values for user profile images
    @available(iOS 15.0, *)
    public enum AvatarSize {
        public static let small: CGFloat = 32
        public static let medium: CGFloat = 40
        public static let large: CGFloat = 56
        public static let xLarge: CGFloat = 80
    }

    // MARK: - Opacity Tokens

    /// Opacity values for consistent transparency effects
    @available(iOS 15.0, *)
    public enum OpacityTokens {
        public static let disabled: Double = 0.3
        public static let secondary: Double = 0.6
        public static let overlay: Double = 0.8
        public static let full: Double = 1.0
    }

    // MARK: - Type Alias

    /// Shortened alias for DesignTokens - consider removing for clarity
    @available(iOS 15.0, *)
    public typealias DesignToken = DesignTokens
#endif
