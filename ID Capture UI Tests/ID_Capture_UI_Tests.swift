//
//  ID_Capture_UI_Tests.swift
//  ID Capture UI Tests
//
//  Created by Jakub Dolejs on 20/04/2020.
//  Copyright © 2020 Applied Recognition Inc. All rights reserved.
//

import XCTest

class ID_Capture_UI_Tests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments.append("--test")
    }

    func testIDCapture() throws {
        app.launch()
        app.buttons.matching(identifier: "scanCard").firstMatch.tap()
        XCTAssertTrue(app.buttons.matching(identifier: "compareToSelfie").firstMatch.waitForExistence(timeout: 5))
    }
    
    func testIDCaptureCancelation() throws {
        app.launchArguments.append("--cancelIDCapture")
        app.launch()
        app.buttons.matching(identifier: "scanCard").firstMatch.tap()
        XCTAssertFalse(app.buttons.matching(identifier: "compareToSelfie").firstMatch.exists)
    }
    
    func testFailDetectingFaceOnIDCard() throws {
        app.launchArguments.append("--failFaceOnIDCard")
        app.launch()
        app.buttons.matching(identifier: "scanCard").firstMatch.tap()
        XCTAssertTrue(app.alerts["Error"].waitForExistence(timeout: 5))
    }
    
    func testCardDetails() throws {
        try self.testIDCapture()
        XCTAssertTrue(app.images.matching(identifier: "cardImage").firstMatch.exists)
        app.images.matching(identifier: "cardImage").firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Card details"].exists)
    }
    
    func testCardDetails2() throws {
        try self.testIDCapture()
        XCTAssertTrue(app.navigationBars["Your ID card"].buttons["Details"].exists)
        app.navigationBars["Your ID card"].buttons["Details"].tap()
        XCTAssertTrue(app.navigationBars["Card details"].exists)
    }
    
    func testMicroblinkIDCapture() throws {
        app.launch()
        app.navigationBars["ID capture"].buttons["Settings"].tap()
        let microblinkSwitch = app.tables.firstMatch.switches.matching(identifier: "microblinkSwitch").firstMatch
        if let val = microblinkSwitch.value as? String, val == "0" {
            microblinkSwitch.tap()
        }
        XCTAssertEqual(microblinkSwitch.value as? String, "1")
        app.navigationBars["Settings"].buttons["Scan ID card"].tap()
        try self.testIDCapture()
    }
    
    func testLivenessDetection() throws {
        try self.testIDCapture()
        app.buttons.matching(identifier: "compareToSelfie").firstMatch.tap()
        XCTAssertTrue(app.staticTexts.matching(identifier: "score").firstMatch.waitForExistence(timeout: 2))
        XCTAssertEqual(app.staticTexts.matching(identifier: "score").firstMatch.label, "3.86")
    }
    
    func testLivenessDetectionFailure() throws {
        app.launchArguments.append("--failLivenessDetection")
        try self.testIDCapture()
        app.buttons.matching(identifier: "compareToSelfie").firstMatch.tap()
        XCTAssertTrue(app.alerts["Failed to capture live face"].waitForExistence(timeout: 2))
    }
    
    func testDisplayFalseAcceptanceRates() throws {
        try self.testLivenessDetection()
        app.buttons.matching(identifier: "far").firstMatch.tap()
        XCTAssertTrue(app.navigationBars["False acceptance rates"].exists)
    }
}
