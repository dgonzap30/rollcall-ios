//
// TabTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class TabTests: XCTestCase {
    // MARK: - Enum Cases Tests

    func test_allCases() {
        let allCases = Tab.allCases

        XCTAssertEqual(allCases.count, 3)
        XCTAssertTrue(allCases.contains(.feed))
        XCTAssertTrue(allCases.contains(.create))
        XCTAssertTrue(allCases.contains(.profile))
    }

    // MARK: - System Image Tests

    func test_systemImage_returnsCorrectSystemNames() {
        XCTAssertEqual(Tab.feed.systemImage, "house.fill")
        XCTAssertEqual(Tab.create.systemImage, "plus.circle.fill")
        XCTAssertEqual(Tab.profile.systemImage, "person.fill")
    }

    // MARK: - Title Tests

    func test_title_returnsCorrectValues() {
        XCTAssertEqual(Tab.feed.title, "Feed")
        XCTAssertEqual(Tab.create.title, "Create")
        XCTAssertEqual(Tab.profile.title, "Profile")
    }

    // MARK: - Raw Value Tests

    func test_rawValue_isUnique() {
        let rawValues = Tab.allCases.map(\.rawValue)
        let uniqueRawValues = Set(rawValues)

        XCTAssertEqual(rawValues.count, uniqueRawValues.count)
    }

    func test_initFromRawValue() {
        XCTAssertEqual(Tab(rawValue: 0), .feed)
        XCTAssertEqual(Tab(rawValue: 1), .create)
        XCTAssertEqual(Tab(rawValue: 2), .profile)
        XCTAssertNil(Tab(rawValue: 99))
    }

    // MARK: - Hashable Tests

    func test_hashable() {
        var set = Set<Tab>()
        set.insert(.feed)
        set.insert(.create)
        set.insert(.profile)
        set.insert(.feed) // Duplicate

        XCTAssertEqual(set.count, 3)
    }

    // MARK: - Sendable Tests

    func test_sendable_canBeSentAcrossActors() async {
        let tab = Tab.profile

        actor TestActor {
            func process(tab: Tab) -> String {
                tab.title
            }
        }

        let actor = TestActor()
        let title = await actor.process(tab: tab)

        XCTAssertEqual(title, "Profile")
    }
}
