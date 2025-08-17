//
// UIViewControllerWrapper.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/08/25.
//

import SwiftUI
import UIKit

@available(iOS 15.0, *)
struct UIViewControllerWrapper: UIViewControllerRepresentable {
    let viewController: UIViewController

    func makeUIViewController(context _: Context) -> UIViewController {
        self.viewController
    }

    func updateUIViewController(_: UIViewController, context _: Context) {
        // No updates needed
    }
}
