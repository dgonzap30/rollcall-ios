//
// RootView.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import SwiftUI

@available(iOS 15.0, *)
struct RootView: View {
    @StateObject private var appCoordinator = AppCoordinator.shared

    var body: some View {
        Group {
            if self.appCoordinator.isOnboarding {
                self.appCoordinator.createOnboardingView()
                    .transition(.opacity)
            } else {
                self.appCoordinator.createMainView()
                    .transition(.opacity)
            }
        }
        .animation(AnimationTokens.Curve.easeInOut, value: self.appCoordinator.isOnboarding)
    }
}

#if DEBUG
    @available(iOS 15.0, *)
    struct RootView_Previews: PreviewProvider {
        static var previews: some View {
            RootView()
        }
    }
#endif
