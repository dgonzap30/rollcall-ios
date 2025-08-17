//
// Container.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import Foundation

@available(iOS 15.0, macOS 12.0, *)
public protocol Container {
    func register<T>(_ type: T.Type, factory: @escaping () -> T)
    func register<T>(_ type: T.Type, instance: T)
    func registerSingleton<T>(_ type: T.Type, factory: @escaping () -> T)
    func resolve<T>(_ type: T.Type) -> T
    func resolve<T>(_ type: T.Type) -> T?
}

@available(iOS 15.0, macOS 12.0, *)
public final class DIContainer: Container {
    private var services: [String: Any] = [:]
    private var factories: [String: () -> Any] = [:]
    private var transientTypes: Set<String> = []
    private let lock = NSLock()

    public init() {}

    // MARK: - Registration

    public func register<T>(_ type: T.Type, factory: @escaping () -> T) {
        self.lock.lock()
        defer { lock.unlock() }

        let key = String(describing: type)
        self.factories[key] = factory
        self.services.removeValue(forKey: key) // Remove any existing instance
        self.transientTypes.remove(key) // Clear transient flag
    }

    public func register<T>(_ type: T.Type, instance: T) {
        self.lock.lock()
        defer { lock.unlock() }

        let key = String(describing: type)
        self.services[key] = instance
        self.factories.removeValue(forKey: key) // Remove any existing factory
        self.transientTypes.remove(key) // Clear transient flag
    }

    // MARK: - Resolution

    public func resolve<T>(_ type: T.Type) -> T {
        guard let instance: T = resolve(type) else {
            fatalError("Service of type \(type) not registered. Please register it before resolving.")
        }
        return instance
    }

    public func resolve<T>(_ type: T.Type) -> T? {
        self.lock.lock()
        defer { lock.unlock() }

        let key = String(describing: type)

        // Check for existing instance (not for transients)
        if !self.transientTypes.contains(key), let instance = services[key] as? T {
            return instance
        }

        // Check for factory
        if let factory = factories[key] {
            let instance = factory() as? T
            // Cache instance for singleton behavior (not for transients)
            if let instance, !transientTypes.contains(key) {
                self.services[key] = instance
            }
            return instance
        }

        return nil
    }

    // MARK: - Testing Support

    public func reset() {
        self.lock.lock()
        defer { lock.unlock() }

        self.services.removeAll()
        self.factories.removeAll()
        self.transientTypes.removeAll()
    }
}

// MARK: - Convenience Extensions

@available(iOS 15.0, macOS 12.0, *)
public extension DIContainer {
    /// Register a service as a singleton (lazy instantiation)
    func registerSingleton<T>(_ type: T.Type, factory: @escaping () -> T) {
        self.register(type, factory: factory)
    }

    /// Register a service as a transient (new instance each time)
    func registerTransient<T>(_ type: T.Type, factory: @escaping () -> T) {
        self.lock.lock()
        defer { lock.unlock() }

        let key = String(describing: type)
        self.factories[key] = factory
        self.transientTypes.insert(key)
        self.services.removeValue(forKey: key) // Remove any cached instance
    }
}

// MARK: - Property Wrapper for Injection

// Property wrappers removed - use explicit dependency injection instead
