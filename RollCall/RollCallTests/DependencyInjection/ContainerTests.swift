//
// ContainerTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

@testable import RollCall
import XCTest

@available(iOS 15.0, macOS 12.0, *)
final class ContainerTests: XCTestCase {
    var container: DIContainer!

    override func setUp() {
        super.setUp()
        self.container = DIContainer()
        self.container.reset() // Ensure clean state
    }

    override func tearDown() {
        self.container.reset()
        self.container = nil
        super.tearDown()
    }

    // MARK: - Registration Tests

    func test_registerInstance_shouldStoreInstance() {
        // Given
        let testService = MockTestService()

        // When
        self.container.register(TestServiceProtocol.self, instance: testService)

        // Then
        let resolved: TestServiceProtocol = self.container.resolve(TestServiceProtocol.self)
        XCTAssertTrue(resolved is MockTestService)
    }

    func test_registerFactory_shouldCreateInstanceLazily() {
        // Given
        var factoryCallCount = 0
        self.container.register(TestServiceProtocol.self) {
            factoryCallCount += 1
            return MockTestService()
        }

        // When - factory should not be called yet
        XCTAssertEqual(factoryCallCount, 0)

        // Then - factory should be called on first resolve
        let _: TestServiceProtocol = self.container.resolve(TestServiceProtocol.self)
        XCTAssertEqual(factoryCallCount, 1)

        // And - should return cached instance on second resolve
        let _: TestServiceProtocol = self.container.resolve(TestServiceProtocol.self)
        XCTAssertEqual(factoryCallCount, 1)
    }

    func test_registerTransient_shouldCreateNewInstanceEachTime() {
        // Given
        var factoryCallCount = 0
        self.container.registerTransient(TestServiceProtocol.self) {
            factoryCallCount += 1
            return MockTestService()
        }

        // When
        let service1: TestServiceProtocol? = self.container.resolve(TestServiceProtocol.self)
        let service2: TestServiceProtocol? = self.container.resolve(TestServiceProtocol.self)

        // Then
        XCTAssertEqual(factoryCallCount, 2)
        XCTAssertNotNil(service1)
        XCTAssertNotNil(service2)
    }

    // MARK: - Resolution Tests

    func test_resolve_whenServiceNotRegistered_shouldReturnNil() {
        // When
        let service: TestServiceProtocol? = self.container.resolve(TestServiceProtocol.self)

        // Then
        XCTAssertNil(service)
    }

    func test_resolve_nonOptional_whenServiceRegistered_shouldReturnService() {
        // Given
        self.container.register(TestServiceProtocol.self, instance: MockTestService())

        // When
        let service: TestServiceProtocol = self.container.resolve(TestServiceProtocol.self)

        // Then
        XCTAssertTrue(service is MockTestService)
    }

    // MARK: - Dependency Injection Tests

    func test_manualDependencyInjection_shouldResolveService() {
        // Given
        self.container.register(TestServiceProtocol.self, instance: MockTestService())

        // When
        let testObject = TestObjectWithManualInjection(container: container)

        // Then
        XCTAssertNotNil(testObject.service)
        XCTAssertTrue(testObject.service is MockTestService)
    }

    func test_optionalDependencyInjection_whenServiceNotRegistered_shouldReturnNil() {
        // Given - no service registered

        // When
        let testObject = TestObjectWithOptionalInjection(container: container)

        // Then
        XCTAssertNil(testObject.service)
    }

    // MARK: - Service Registration Integration Tests

    func test_serviceRegistration_shouldRegisterAllServices() {
        // Given
        let registration = ServiceRegistration(container: container)

        // When
        registration.registerTestServices()

        // Then
        let authService: AuthServicing? = self.container.resolve(AuthServicing.self)
        let hapticService: HapticFeedbackServicing? = self.container.resolve(HapticFeedbackServicing.self)

        XCTAssertNotNil(authService)
        XCTAssertNotNil(hapticService)
        XCTAssertTrue(authService is MockAuthService)
        XCTAssertTrue(hapticService is NoOpHapticFeedbackService)
    }

    func test_reset_shouldClearAllRegistrations() {
        // Given
        self.container.register(TestServiceProtocol.self, instance: MockTestService())
        let serviceBeforeReset: TestServiceProtocol? = self.container.resolve(TestServiceProtocol.self)
        XCTAssertNotNil(serviceBeforeReset)

        // When
        self.container.reset()

        // Then
        let serviceAfterReset: TestServiceProtocol? = self.container.resolve(TestServiceProtocol.self)
        XCTAssertNil(serviceAfterReset)
    }

    // MARK: - Thread Safety Tests

    func test_concurrentAccess_shouldBeThreadSafe() {
        // Given
        let expectation = XCTestExpectation(description: "Concurrent access")
        expectation.expectedFulfillmentCount = 100

        self.container.register(TestServiceProtocol.self) {
            MockTestService()
        }

        // When
        DispatchQueue.concurrentPerform(iterations: 100) { _ in
            let _: TestServiceProtocol? = self.container.resolve(TestServiceProtocol.self)
            expectation.fulfill()
        }

        // Then
        wait(for: [expectation], timeout: 0.5)
    }
}

// MARK: - Test Helpers

@available(iOS 15.0, macOS 12.0, *)
private protocol TestServiceProtocol {}

@available(iOS 15.0, macOS 12.0, *)
private class MockTestService: TestServiceProtocol {}

@available(iOS 15.0, macOS 12.0, *)
private class TestObjectWithManualInjection {
    let service: TestServiceProtocol

    init(container: Container) {
        self.service = container.resolve(TestServiceProtocol.self)
    }
}

@available(iOS 15.0, macOS 12.0, *)
private class TestObjectWithOptionalInjection {
    let service: TestServiceProtocol?

    init(container: Container) {
        self.service = container.resolve(TestServiceProtocol.self)
    }
}
