//
//  yCHMUITests.swift
//  yCHMUITests
//
//  Created by simon xu on 4/22/22.
//

import XCTest

class yCHMUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // UI tests must launch the application that they test.
        let bundle = Bundle(for: type(of: self))
        let chmpath = bundle.path(forResource: "PowerCollections", ofType: "chm")!
        
        let app = XCUIApplication()
        app.launch()

        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let addButton = app.windows.buttons["Open"]
        XCTAssert(addButton.exists)
        addButton.click()
        let openDialog = app.dialogs.firstMatch
        XCTAssert(openDialog.waitForExistence(timeout: 5))
        // Make sure we're on the right type of dialog by checking the "Where:" popover button exists
        // Also grab a reference to the Open button so we can click it later
        let openButton = openDialog.buttons["Open"]
        let whereButton = openDialog.popUpButtons["Where:"]
        XCTAssert(whereButton.exists)
        XCTAssert(openButton.exists)
        app.typeKey("g", modifierFlags: [.command, .shift])
        let sheet = openDialog.sheets.firstMatch
        XCTAssert(sheet.waitForExistence(timeout: 5))
        let goButton = openDialog.buttons["Go"]
        let input = sheet.comboBoxes.firstMatch
        XCTAssert(goButton.exists)
        XCTAssert(input.exists)
        input.typeText(chmpath)
        goButton.click()
        openButton.click()
        
        let ychmContentview1Appwindow1Window = XCUIApplication()/*@START_MENU_TOKEN@*/.windows["yCHM.ContentView-1-AppWindow-1"]/*[[".windows[\"yCHM\"]",".windows[\"yCHM.ContentView-1-AppWindow-1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
        ychmContentview1Appwindow1Window/*@START_MENU_TOKEN@*/.outlines.children(matching: .outlineRow).element(boundBy: 1).disclosureTriangles["NSOutlineViewDisclosureButtonKey"]/*[[".scrollViews.outlines.children(matching: .outlineRow).element(boundBy: 1)",".cells.disclosureTriangles[\"NSOutlineViewDisclosureButtonKey\"]",".disclosureTriangles[\"NSOutlineViewDisclosureButtonKey\"]",".outlines.children(matching: .outlineRow).element(boundBy: 1)"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.click()
        let item = ychmContentview1Appwindow1Window/*@START_MENU_TOKEN@*/.outlines.buttons["Algorithms Methods"]/*[[".scrollViews.outlines",".outlineRows",".cells.buttons[\"Algorithms Methods\"]",".buttons[\"Algorithms Methods\"]",".outlines"],[[[-1,4,1],[-1,0,1]],[[-1,3],[-1,2],[-1,1,2]],[[-1,3],[-1,2]]],[0,0]]@END_MENU_TOKEN@*/
        XCTAssert(item.waitForExistence(timeout: 5))
        item.click()
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
