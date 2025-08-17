//
// RollCallApp.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import SwiftUI
#if os(iOS)
    import UIKit
#endif

@available(iOS 15.0, macOS 12.0, *)
@main
struct RollCallApp: App {
    #if os(iOS)
        @UIApplicationDelegateAdaptor(AppDelegate.self)
        var appDelegate
    #endif

    var body: some Scene {
        WindowGroup {
            #if os(iOS)
                // Use RootView to properly observe AppCoordinator state changes
                RootView()
            #else
                EmptyView()
            #endif
        }
    }
}

#if os(iOS)
    @available(iOS 15.0, *)
    class AppDelegate: UIResponder, UIApplicationDelegate {
        var window: UIWindow?

        func application(
            _: UIApplication,
            didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
        ) -> Bool {
            // AppCoordinator.shared initializes and registers services automatically
            _ = AppCoordinator.shared
            return true
        }
    }
#endif
