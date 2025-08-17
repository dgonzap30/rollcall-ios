//
// MockHapticFeedbackService.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation
@testable import RollCall

@available(iOS 15.0, macOS 12.0, *)
final class MockHapticFeedbackService: HapticFeedbackServicing {
    var invokedImpact = false
    var invokedImpactCount = 0
    var invokedImpactStyle: HapticFeedbackStyle?

    var invokedNotification = false
    var invokedNotificationCount = 0
    var invokedNotificationType: HapticNotificationType?

    // Legacy API for backward compatibility
    private(set) var impactCalls: [(style: HapticFeedbackStyle, timestamp: Date)] = []
    var impactCallCount: Int { self.invokedImpactCount }
    var lastImpactStyle: HapticFeedbackStyle? { self.invokedImpactStyle }

    func impact(style: HapticFeedbackStyle) async {
        self.invokedImpact = true
        self.invokedImpactCount += 1
        self.invokedImpactStyle = style
        self.impactCalls.append((style: style, timestamp: Date()))
    }

    func notification(type: HapticNotificationType) async {
        self.invokedNotification = true
        self.invokedNotificationCount += 1
        self.invokedNotificationType = type
    }

    func reset() {
        self.invokedImpact = false
        self.invokedImpactCount = 0
        self.invokedImpactStyle = nil
        self.invokedNotification = false
        self.invokedNotificationCount = 0
        self.invokedNotificationType = nil
        self.impactCalls.removeAll()
    }
}
