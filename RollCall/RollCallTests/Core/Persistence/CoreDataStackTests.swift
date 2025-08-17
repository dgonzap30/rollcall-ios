//
// CoreDataStackTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

import CoreData
@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class CoreDataStackTests: XCTestCase {
    var sut: CoreDataStack!

    override func setUp() {
        super.setUp()
        self.sut = CoreDataStack.makeTestStack()
    }

    override func tearDown() {
        self.sut = nil
        super.tearDown()
    }

    func test_init_createsInMemoryStore() {
        XCTAssertNotNil(self.sut.viewContext)
        XCTAssertTrue(self.sut.viewContext.persistentStoreCoordinator?.persistentStores.first?
            .type == NSInMemoryStoreType
        )
    }

    func test_performBackgroundTask_executesOnBackgroundContext() async throws {
        let expectation = XCTestExpectation(description: "Background task executed")

        let result = try await sut.performBackgroundTask { context in
            XCTAssertFalse(Thread.isMainThread)
            XCTAssertNotEqual(context, self.sut.viewContext)
            expectation.fulfill()
            return "Success"
        }

        XCTAssertEqual(result, "Success")
        await fulfillment(of: [expectation], timeout: 1.0)
    }

    func test_save_persistsChanges() async throws {
        let context = self.sut.viewContext
        let chef = ChefEntity(context: context)
        chef.id = UUID()
        chef.username = "testchef"
        chef.displayName = "Test Chef"
        chef.email = "test@example.com"
        chef.joinedAt = Date()
        chef.lastActiveAt = Date()
        chef.rollCount = 0

        try self.sut.save(context: context)

        let request = ChefEntity.fetchRequest()
        let results = try context.fetch(request)
        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.username, "testchef")
    }

    func test_deleteAllData_removesAllEntities() async throws {
        let context = self.sut.viewContext

        let chef = ChefEntity(context: context)
        chef.id = UUID()
        chef.username = "testchef"
        chef.displayName = "Test Chef"
        chef.email = "test@example.com"
        chef.joinedAt = Date()
        chef.lastActiveAt = Date()
        chef.rollCount = 0

        try self.sut.save(context: context)

        let countBefore = try context.count(for: ChefEntity.fetchRequest())
        XCTAssertEqual(countBefore, 1)

        try await self.sut.deleteAllData()

        let countAfter = try context.count(for: ChefEntity.fetchRequest())
        XCTAssertEqual(countAfter, 0)
    }
}
