//
// NoOpAccessibilityService.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

@available(iOS 15.0, *)
public final class NoOpAccessibilityService: AccessibilityServicing {
    public var isReduceMotionEnabled: Bool = false

    public init() {}
}
