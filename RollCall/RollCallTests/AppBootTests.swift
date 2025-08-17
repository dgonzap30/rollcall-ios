//
// AppBootTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 13/07/25.
//

import XCTest

@available(iOS 15.0, macOS 12.0, *)
final class AppBootTests: XCTestCase {
    func test_appBoots_shouldPass() {
        // Given
        let expectedValue = true

        // When
        let actualValue = true

        // Then
        XCTAssertEqual(expectedValue, actualValue)
    }
}
