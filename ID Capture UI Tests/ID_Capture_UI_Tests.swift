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
    
    func scanIDCard() {
        XCTAssertTrue(app.buttons.matching(identifier: "scanCard").firstMatch.waitForExistence(timeout: 10))
        app.buttons.matching(identifier: "scanCard").firstMatch.tap()
        XCTAssertTrue(app.buttons.matching(identifier: "compareToSelfie").firstMatch.waitForExistence(timeout: 10))
    }

    func testIDCapture() {
        app.launch()
        scanIDCard()
    }
    
    func testIDCaptureWithRotatedImage() throws {
        app.launchArguments.append("--rotatedCardImage")
        app.launch()
        XCTAssertTrue(app.buttons.matching(identifier: "scanCard").firstMatch.waitForExistence(timeout: 10))
        app.buttons.matching(identifier: "scanCard").firstMatch.tap()
        XCTAssertTrue(app.buttons.matching(identifier: "compareToSelfie").firstMatch.waitForExistence(timeout: 5))
    }
    
    func testIDCaptureWithLowQualityFace() throws {
        app.launchArguments.append("--lowQualityCardFace")
        app.launch()
        XCTAssertTrue(app.buttons.matching(identifier: "scanCard").firstMatch.waitForExistence(timeout: 10))
        app.buttons.matching(identifier: "scanCard").firstMatch.tap()
        XCTAssertTrue(app.buttons.matching(identifier: "compareToSelfie").firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons.matching(identifier: "qualityWarning").firstMatch.exists)
        app.buttons.matching(identifier: "qualityWarning").firstMatch.tap()
        XCTAssertTrue(app.alerts["Warning"].exists)
    }
    
    func testIDCaptureCancelation() throws {
        app.launchArguments.append("--cancelIDCapture")
        app.launch()
        XCTAssertTrue(app.buttons.matching(identifier: "scanCard").firstMatch.waitForExistence(timeout: 10))
        app.buttons.matching(identifier: "scanCard").firstMatch.tap()
        XCTAssertFalse(app.buttons.matching(identifier: "compareToSelfie").firstMatch.exists)
    }
    
    func testFaceComparisonWithLowQualityFace() throws {
        try self.testIDCaptureWithLowQualityFace()
        app.alerts["Warning"].buttons["OK"].tap()
        app.buttons.matching(identifier: "compareToSelfie").firstMatch.tap()
        XCTAssertTrue(app.staticTexts.matching(identifier: "score").firstMatch.waitForExistence(timeout: 2))
    }
    
    func testFailDetectingFaceOnIDCard() throws {
        app.launchArguments.append("--failFaceOnIDCard")
        app.launch()
        XCTAssertTrue(app.buttons.matching(identifier: "scanCard").firstMatch.waitForExistence(timeout: 10))
        app.buttons.matching(identifier: "scanCard").firstMatch.tap()
        XCTAssertTrue(app.alerts["Error"].waitForExistence(timeout: 5))
    }
    
    func testCardDetails() throws {
        self.testIDCapture()
        XCTAssertTrue(app.images.matching(identifier: "cardImage").firstMatch.exists)
        app.images.matching(identifier: "cardImage").firstMatch.tap()
        XCTAssertTrue(app.navigationBars["Card details"].exists)
    }
    
    func testCardDetails2() throws {
        self.testIDCapture()
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
        self.scanIDCard()
    }
    
    func testLivenessDetection() throws {
        self.testIDCapture()
        app.buttons.matching(identifier: "compareToSelfie").firstMatch.tap()
        XCTAssertTrue(app.staticTexts.matching(identifier: "score").firstMatch.waitForExistence(timeout: 2))
        XCTAssertEqual(app.staticTexts.matching(identifier: "score").firstMatch.label, "Pass")
    }
    
    func testLivenessDetectionFailure() throws {
        app.launchArguments.append("--failLivenessDetection")
        self.testIDCapture()
        app.buttons.matching(identifier: "compareToSelfie").firstMatch.tap()
        XCTAssertTrue(app.alerts["Failed to capture live face"].waitForExistence(timeout: 2))
    }
    
    func testAuthenticityScore() throws {
        self.testIDCapture()
        XCTAssertTrue(app.navigationBars["Your ID card"].buttons["Details"].exists)
        app.navigationBars["Your ID card"].buttons["Details"].tap()
        XCTAssertTrue(app.navigationBars["Card details"].exists)
        XCTAssertTrue(app.tables.firstMatch.cells.matching(identifier: "Authenticity score").staticTexts.element(boundBy: 1).exists)
        XCTAssertEqual(app.tables.firstMatch.cells.matching(identifier: "Authenticity score").staticTexts.element(boundBy: 1).label, "1.00")
    }
}
