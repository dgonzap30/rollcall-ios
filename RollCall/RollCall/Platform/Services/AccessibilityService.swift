//
// AccessibilityService.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation
import UIKit

@available(iOS 15.0, *)
public final class AccessibilityService: AccessibilityServicing {
    public init() {}

    public var isReduceMotionEnabled: Bool {
        UIAccessibility.isReduceMotionEnabled
    }
}
