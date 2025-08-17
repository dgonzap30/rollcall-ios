//
// HapticFeedbackService.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation
#if os(iOS)
    import UIKit
#endif

// MARK: - iOS Implementation

@available(iOS 15.0, *)
struct HapticFeedbackService: HapticFeedbackServicing {
    func impact(style: HapticFeedbackStyle) async {
        #if os(iOS)
            await MainActor.run {
                let generator: UIImpactFeedbackGenerator

                switch style {
                case .light:
                    generator = UIImpactFeedbackGenerator(style: .light)
                case .medium:
                    generator = UIImpactFeedbackGenerator(style: .medium)
                case .heavy:
                    generator = UIImpactFeedbackGenerator(style: .heavy)
                case .success:
                    let notificationGenerator = UINotificationFeedbackGenerator()
                    notificationGenerator.notificationOccurred(.success)
                    return
                case .warning:
                    let notificationGenerator = UINotificationFeedbackGenerator()
                    notificationGenerator.notificationOccurred(.warning)
                    return
                case .error:
                    let notificationGenerator = UINotificationFeedbackGenerator()
                    notificationGenerator.notificationOccurred(.error)
                    return
                }

                generator.impactOccurred()
            }
        #endif
    }

    func notification(type: HapticNotificationType) async {
        #if os(iOS)
            await MainActor.run {
                let notificationGenerator = UINotificationFeedbackGenerator()

                switch type {
                case .success:
                    notificationGenerator.notificationOccurred(.success)
                case .warning:
                    notificationGenerator.notificationOccurred(.warning)
                case .error:
                    notificationGenerator.notificationOccurred(.error)
                }
            }
        #endif
    }
}

// MARK: - Factory

@available(iOS 15.0, macOS 12.0, *)
enum HapticFeedbackServiceFactory {
    static func create() -> HapticFeedbackServicing {
        #if os(iOS)
            return HapticFeedbackService()
        #else
            return NoOpHapticFeedbackService()
        #endif
    }
}
