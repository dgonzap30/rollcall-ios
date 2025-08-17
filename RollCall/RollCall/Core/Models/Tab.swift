//
// Tab.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

@available(iOS 15.0, *)
public enum Tab: Int, CaseIterable, Sendable {
    case feed
    case create
    case profile

    public var title: String {
        switch self {
        case .feed:
            "Feed"
        case .create:
            "Create"
        case .profile:
            "Profile"
        }
    }

    public var systemImage: String {
        switch self {
        case .feed:
            "house.fill"
        case .create:
            "plus.circle.fill"
        case .profile:
            "person.fill"
        }
    }

    public var icon: String {
        switch self {
        case .feed:
            "house"
        case .create:
            "plus.circle"
        case .profile:
            "person"
        }
    }

    public var selectedIcon: String {
        switch self {
        case .feed:
            "house.fill"
        case .create:
            "plus.circle.fill"
        case .profile:
            "person.fill"
        }
    }
}
