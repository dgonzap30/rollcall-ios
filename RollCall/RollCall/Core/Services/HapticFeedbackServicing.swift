//
// HapticFeedbackServicing.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

// MARK: - Haptic Feedback Style

@available(iOS 15.0, macOS 12.0, *)
public enum HapticFeedbackStyle {
    case light
    case medium
    case heavy
    case success
    case warning
    case error
}

// MARK: - Notification Type

@available(iOS 15.0, macOS 12.0, *)
public enum HapticNotificationType {
    case success
    case warning
    case error
}

// MARK: - Protocol

@available(iOS 15.0, macOS 12.0, *)
public protocol HapticFeedbackServicing {
    func impact(style: HapticFeedbackStyle) async
    func notification(type: HapticNotificationType) async
}

// MARK: - No-Op Implementation

@available(iOS 15.0, macOS 12.0, *)
public struct NoOpHapticFeedbackService: HapticFeedbackServicing {
    public init() {}

    public func impact(style _: HapticFeedbackStyle) async {
        // No-op for non-iOS platforms or testing
    }

    public func notification(type _: HapticNotificationType) async {
        // No-op for non-iOS platforms or testing
    }
}
