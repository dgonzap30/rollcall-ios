//
// OnboardingViewStateTests.swift
// RollCall
//
// Created by Gonzalez <diego.gonzap30@gmail.com> on 26/07/25.
//

@testable import RollCall
import XCTest

@available(iOS 15.0, *)
final class OnboardingViewStateTests: XCTestCase {
    func test_init_withDefaultValues_shouldSetCorrectState() {
        let state = OnboardingViewState()

        XCTAssertEqual(state.currentPageIndex, 0)
        XCTAssertEqual(state.pages.count, 3)
        XCTAssertFalse(state.isSkipVisible)
        XCTAssertFalse(state.isLastPage)
        XCTAssertTrue(state.canNavigateForward)
        XCTAssertNotNil(state.currentPage)
        XCTAssertEqual(state.currentPage?.id, 0)
    }

    func test_init_withCustomPages_shouldUseCustomPages() {
        let customPages = [
            OnboardingPage(id: 0, illustration: "test1", title: "Test 1", subtitle: "Subtitle 1", buttonTitle: "Next"),
            OnboardingPage(id: 1, illustration: "test2", title: "Test 2", subtitle: "Subtitle 2", buttonTitle: "Done")
        ]

        let state = OnboardingViewState(currentPageIndex: 0, pages: customPages)

        XCTAssertEqual(state.pages.count, 2)
        XCTAssertEqual(state.pages, customPages)
    }

    func test_isSkipVisible_shouldBeCorrectForDifferentPages() {
        let pages = OnboardingPage.pages

        // First page - no skip
        let firstPageState = OnboardingViewState(currentPageIndex: 0, pages: pages)
        XCTAssertFalse(firstPageState.isSkipVisible)

        // Middle page - should show skip
        let middlePageState = OnboardingViewState(currentPageIndex: 1, pages: pages)
        XCTAssertTrue(middlePageState.isSkipVisible)

        // Last page - no skip
        let lastPageState = OnboardingViewState(currentPageIndex: 2, pages: pages)
        XCTAssertFalse(lastPageState.isSkipVisible)
    }

    func test_isLastPage_shouldBeCorrectForDifferentPages() {
        let pages = OnboardingPage.pages

        let firstPageState = OnboardingViewState(currentPageIndex: 0, pages: pages)
        XCTAssertFalse(firstPageState.isLastPage)

        let lastPageState = OnboardingViewState(currentPageIndex: 2, pages: pages)
        XCTAssertTrue(lastPageState.isLastPage)
    }

    func test_canNavigateForward_shouldBeCorrectForDifferentPages() {
        let pages = OnboardingPage.pages

        let firstPageState = OnboardingViewState(currentPageIndex: 0, pages: pages)
        XCTAssertTrue(firstPageState.canNavigateForward)

        let lastPageState = OnboardingViewState(currentPageIndex: 2, pages: pages)
        XCTAssertFalse(lastPageState.canNavigateForward)
    }

    func test_currentPage_withValidIndex_shouldReturnCorrectPage() {
        let state = OnboardingViewState(currentPageIndex: 1)

        XCTAssertNotNil(state.currentPage)
        XCTAssertEqual(state.currentPage?.id, 1)
        XCTAssertEqual(state.currentPage?.title, "Track Your Sushi Journey")
    }

    func test_currentPage_withInvalidIndex_shouldReturnNil() {
        let negativeIndexState = OnboardingViewState(currentPageIndex: -1)
        XCTAssertNil(negativeIndexState.currentPage)

        let outOfBoundsState = OnboardingViewState(currentPageIndex: 10)
        XCTAssertNil(outOfBoundsState.currentPage)
    }

    func test_equatable_shouldWorkCorrectly() {
        let state1 = OnboardingViewState(currentPageIndex: 0)
        let state2 = OnboardingViewState(currentPageIndex: 0)
        let state3 = OnboardingViewState(currentPageIndex: 1)

        XCTAssertEqual(state1, state2)
        XCTAssertNotEqual(state1, state3)
    }
}

// MARK: - OnboardingPage Tests

@available(iOS 15.0, *)
final class OnboardingPageTests: XCTestCase {
    func test_defaultPages_shouldHaveCorrectContent() {
        let pages = OnboardingPage.pages

        XCTAssertEqual(pages.count, 3)

        // Welcome page
        XCTAssertEqual(pages[0].id, 0)
        XCTAssertEqual(pages[0].illustration, "welcome")
        XCTAssertEqual(pages[0].title, "Welcome to RollCall")
        XCTAssertEqual(pages[0].subtitle, "Your personal sushi journey starts here")
        XCTAssertEqual(pages[0].buttonTitle, "Get Started")

        // Track page
        XCTAssertEqual(pages[1].id, 1)
        XCTAssertEqual(pages[1].illustration, "track_rolls")
        XCTAssertEqual(pages[1].title, "Track Your Sushi Journey")
        XCTAssertEqual(pages[1].subtitle, "Log every roll, rate your favorites, and build your personal sushi diary")
        XCTAssertEqual(pages[1].buttonTitle, "Next")

        // Discover page
        XCTAssertEqual(pages[2].id, 2)
        XCTAssertEqual(pages[2].illustration, "discover_share")
        XCTAssertEqual(pages[2].title, "Discover & Share")
        XCTAssertEqual(
            pages[2].subtitle,
            "Find amazing restaurants, follow fellow chefs, and share your sushi adventures"
        )
        XCTAssertEqual(pages[2].buttonTitle, "Start Rolling")
    }

    func test_onboardingPage_shouldBeIdentifiable() {
        let page = OnboardingPage(id: 99, illustration: "test", title: "Test", subtitle: "Test", buttonTitle: nil)
        XCTAssertEqual(page.id, 99)
    }

    func test_onboardingPage_shouldBeEquatable() {
        let page1 = OnboardingPage(id: 1, illustration: "test", title: "Test", subtitle: "Test", buttonTitle: "Next")
        let page2 = OnboardingPage(id: 1, illustration: "test", title: "Test", subtitle: "Test", buttonTitle: "Next")
        let page3 = OnboardingPage(id: 2, illustration: "test", title: "Test", subtitle: "Test", buttonTitle: "Next")

        XCTAssertEqual(page1, page2)
        XCTAssertNotEqual(page1, page3)
    }
}
