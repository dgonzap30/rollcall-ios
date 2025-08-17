//
// WelcomeViewState.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

@available(iOS 15.0, *)
public struct WelcomeViewState: Equatable {
    public struct LogoState: Equatable {
        var scale: Double = 0.5
        var opacity: Double = 0.0
        var rotation: Double = -5.0
        var floatingOffset: Double = 0.0
        var pulseScale: Double = 1.0
    }

    public struct ContentState: Equatable {
        var titleOpacity: Double = 0.0
        var subtitleOpacity: Double = 0.0
        var taglineOpacity: Double = 0.0
    }

    public struct ButtonState: Equatable {
        var scale: Double = 0.8
        var opacity: Double = 0.0
        var isPressed: Bool = false
    }

    public var logo = LogoState()
    public var content = ContentState()
    public var button = ButtonState()
    public var showParticles: Bool = false
    public var animationPhase: AnimationPhase = .initial

    public enum AnimationPhase: Int, Equatable {
        case initial = 0
        case logoIn = 1
        case contentIn = 2
        case buttonIn = 3
        case complete = 4
    }

    public static let initial = Self()

    public mutating func nextPhase() {
        switch self.animationPhase {
        case .initial:
            self.animationPhase = .logoIn
            self.logo.scale = 1.0
            self.logo.opacity = 1.0
            self.logo.rotation = 0.0
        case .logoIn:
            self.animationPhase = .contentIn
            self.content.titleOpacity = 1.0
            self.content.subtitleOpacity = 1.0
            self.content.taglineOpacity = 0.8
            self.logo.floatingOffset = -2.0
            self.logo.pulseScale = 1.02
        case .contentIn:
            self.animationPhase = .buttonIn
            self.button.scale = 1.0
            self.button.opacity = 1.0
        case .buttonIn:
            self.animationPhase = .complete
            self.showParticles = true
        case .complete:
            break
        }
    }

    public mutating func setButtonPressed(_ pressed: Bool) {
        self.button.isPressed = pressed
    }
}
