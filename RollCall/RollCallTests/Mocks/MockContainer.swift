//
// MockContainer.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation
@testable import RollCall

@available(iOS 15.0, *)
final class MockContainer: Container {
    private var services: [String: Any] = [:]
    private var factories: [String: () -> Any] = [:]
    private(set) var registeredTypes: Set<String> = []

    func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        let key = String(describing: type)
        self.registeredTypes.insert(key)
        self.factories[key] = factory
    }

    func register<T>(_ type: T.Type, instance: T) {
        let key = String(describing: type)
        self.registeredTypes.insert(key)
        self.services[key] = instance
    }

    func registerSingleton<T>(_ type: T.Type, factory: @escaping () -> T) {
        self.register(type, factory: factory)
    }

    func resolve<T>(_ type: T.Type) -> T {
        guard let instance: T = resolve(type) else {
            fatalError("Service of type \(type) not registered")
        }
        return instance
    }

    func resolve<T>(_ type: T.Type) -> T? {
        let key = String(describing: type)

        if let instance = services[key] as? T {
            return instance
        }

        if let factory = factories[key] {
            let instance = factory() as? T
            if let instance {
                self.services[key] = instance
            }
            return instance
        }

        return nil
    }

    // Test helpers
    func hasRegistered(_ type: (some Any).Type) -> Bool {
        let key = String(describing: type)
        return self.registeredTypes.contains(key)
    }

    func reset() {
        self.services.removeAll()
        self.registeredTypes.removeAll()
    }
}
