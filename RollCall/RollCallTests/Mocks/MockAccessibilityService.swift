//
// MockAccessibilityService.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation
@testable import RollCall

@available(iOS 15.0, *)
final class MockAccessibilityService: AccessibilityServicing {
    var isReduceMotionEnabled: Bool = false

    init() {}
}
