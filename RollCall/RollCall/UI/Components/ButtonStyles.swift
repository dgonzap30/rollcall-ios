//
// ButtonStyles.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

#if canImport(SwiftUI)
    import SwiftUI

    // MARK: - Scale Button Style

    @available(iOS 15.0, *)
    public struct ScaleButtonStyle: ButtonStyle {
        public init() {}

        public func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
        }
    }

#endif
