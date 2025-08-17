//
// MainTabCoordinating.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation
import SwiftUI

@available(iOS 15.0, *)
public protocol MainTabCoordinating: AnyObject {
    @MainActor
    func handleTabSelection(_ tab: Tab)
    @MainActor
    func showCreateRoll()
}

@available(iOS 15.0, *)
public protocol MainTabCoordinatorDelegate: AnyObject {
    @MainActor
    func mainTabCoordinatorDidRequestReset(_ coordinator: MainTabCoordinator)
}
