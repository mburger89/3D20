//
//  _D20UITests.swift
//  3D20UITests
//
//  Created by Anson Burger on 12/3/24.
//

import XCTest

final class _D20UITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Main Screen

    @MainActor
    func testHUDButtonsVisible() throws {
        XCTAssertTrue(app.buttons["change-skin-button"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["change-dice-button"].exists)
    }

    @MainActor
    func testViewModePickerHasSegments() throws {
        XCTAssertTrue(app.buttons["3D"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["AR"].exists)
    }

    @MainActor
    func testChangeSkinOpensSheet() throws {
        XCTAssertTrue(app.buttons["change-skin-button"].waitForExistence(timeout: 5))
        app.buttons["change-skin-button"].tap()
        // Skins sheet has a segmented picker with "Dice" and "Tray" options
        XCTAssertTrue(app.buttons["Dice"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Tray"].exists)
    }

    @MainActor
    func testChangeDiceOpensSheet() throws {
        XCTAssertTrue(app.buttons["change-dice-button"].waitForExistence(timeout: 5))
        app.buttons["change-dice-button"].tap()
        XCTAssertTrue(app.buttons["D20-button"].waitForExistence(timeout: 3))
    }

    // MARK: - Store

    @MainActor
    func testNavigateToStore() throws {
        XCTAssertTrue(app.buttons["store-link"].waitForExistence(timeout: 5))
        app.buttons["store-link"].tap()
        XCTAssertTrue(app.navigationBars["Dice Store"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testStoreCategoryButtonsVisible() throws {
        XCTAssertTrue(app.buttons["store-link"].waitForExistence(timeout: 5))
        app.buttons["store-link"].tap()
        XCTAssertTrue(app.navigationBars["Dice Store"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Favorites"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.buttons["Metals"].exists)
        XCTAssertTrue(app.buttons["Sci-fi"].exists)
        XCTAssertTrue(app.buttons["Fantasy"].exists)
    }

    @MainActor
    func testStoreCategoryFilterToggle() throws {
        XCTAssertTrue(app.buttons["store-link"].waitForExistence(timeout: 5))
        app.buttons["store-link"].tap()
        XCTAssertTrue(app.buttons["Metals"].waitForExistence(timeout: 5))
        app.buttons["Metals"].tap()
        XCTAssertTrue(app.buttons["Metals"].exists)
        app.buttons["Metals"].tap()
        XCTAssertTrue(app.buttons["Metals"].exists)
    }

    @MainActor
    func testStoreFavoritesEmptyState() throws {
        XCTAssertTrue(app.buttons["store-link"].waitForExistence(timeout: 5))
        app.buttons["store-link"].tap()
        XCTAssertTrue(app.buttons["Favorites"].waitForExistence(timeout: 5))
        app.buttons["Favorites"].tap()
        XCTAssertTrue(app.staticTexts["No Items"].waitForExistence(timeout: 3))
    }

    // MARK: - Dice Bag

    @MainActor
    func testNavigateToDiceBag() throws {
        XCTAssertTrue(app.buttons["dicebag-link"].waitForExistence(timeout: 5))
        app.buttons["dicebag-link"].tap()
        XCTAssertTrue(app.navigationBars["Dice bag"].waitForExistence(timeout: 5))
    }

    @MainActor
    func testDiceBagTabsExist() throws {
        XCTAssertTrue(app.buttons["dicebag-link"].waitForExistence(timeout: 5))
        app.buttons["dicebag-link"].tap()
        XCTAssertTrue(app.navigationBars["Dice bag"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabBars.buttons["Dice"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.tabBars.buttons["Tray"].exists)
    }

    @MainActor
    func testDiceBagSwitchToTrayTab() throws {
        XCTAssertTrue(app.buttons["dicebag-link"].waitForExistence(timeout: 5))
        app.buttons["dicebag-link"].tap()
        XCTAssertTrue(app.navigationBars["Dice bag"].waitForExistence(timeout: 5))
        let trayTab = app.tabBars.buttons["Tray"]
        XCTAssertTrue(trayTab.waitForExistence(timeout: 3))
        trayTab.tap()
        XCTAssertTrue(trayTab.isSelected)
    }
}
