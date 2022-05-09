//
//  yCHMTests.swift
//  yCHMTests
//
//  Created by simon xu on 4/22/22.
//

import XCTest
import Logging
@testable import yCHM

let logger = Logger(label: "yCHMTests")

class yCHMTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLoadPerformance() throws {
        let chmpath = Bundle(for: type(of: self)).path(forResource: "PowerCollections", ofType: "chm")!
        self.measure {
            let _ = CHMFile(filename: chmpath)
        }
    }
    
    func testLoadPerformance7Z() throws {
        let chmpath = Bundle(for: type(of: self)).path(forResource: "7-zip", ofType: "chm")!
        self.measure {
            let _ = CHMFile(filename: chmpath)
        }
    }

    func testFuzzyMatch() throws {
        XCTAssertTrue(fuzzyMatch(query: "", text: "abc"))
        XCTAssertTrue(fuzzyMatch(query: "Abc", text: "abc"))
        XCTAssertTrue(fuzzyMatch(query: "abc", text: "azzzbzzzc"))
        XCTAssertTrue(fuzzyMatch(query: "abc", text: "aaabbbccc"))
        XCTAssertFalse(fuzzyMatch(query: "abc", text: "acb"))
        XCTAssertFalse(fuzzyMatch(query: "aac", text: "ac"))
        XCTAssertFalse(fuzzyMatch(query: "aac", text: ""))
    }
}
