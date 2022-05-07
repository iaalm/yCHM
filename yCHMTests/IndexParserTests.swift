//
//  IndexParserTests.swift
//  yCHMTests
//
//  Created by simon xu on 5/7/22.
//

import XCTest

class IndexParserTests: XCTestCase {
    let testHtml1 = """
        <!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
        <HTML>
            <HEAD>
                <meta name="GENERATOR" content="EasyCHM.exe  www.zipghost.com">
                <!-- Sitemap 1.0 -->
            </HEAD><BODY>
                <OBJECT type="text/site properties">
                    <param name="ExWindow Styles" value="0x200">
                    <param name="Window Styles" value="0x800025">
                    <param name="Font" value="MS Sans Serif,9,0">
                </OBJECT>
                <UL>
                    <LI> <OBJECT type="text/sitemap">
                            <param name="Name" value="a">
                            <param name="Local" value="a.html">
                            <param name="ImageNumber" value="11">
                    </OBJECT></LI>
                    <LI> <OBJECT type="text/sitemap">
                            <param name="Name" value="b">
                            <param name="Local" value="b.html">
                            <param name="ImageNumber" value="1">
                    </OBJECT></LI>
                    <UL>
                        <LI> <OBJECT type="text/sitemap">
                                <param name="Name" value="c">
                                <param name="Local" value="b/c.html">
                                <param name="ImageNumber" value="11">
                        </OBJECT></LI>
                        <LI> <OBJECT type="text/sitemap">
                                <param name="Name" value="specialitem">
                                <param name="Local" value="b/specialitem.html">
                                <param name="ImageNumber" value="1">
                        </OBJECT></LI>
                        <UL>
                            <LI> <OBJECT type="text/sitemap">
                                    <param name="Name" value="e">
                                    <param name="Local" value="b/specialitem/e.html">
                                    <param name="ImageNumber" value="11">
                            </OBJECT></LI>
                            <LI> <OBJECT type="text/sitemap">
                                    <param name="Name" value="f">
                                    <param name="Local" value="b/specialitem/f.html">
                                    <param name="ImageNumber" value="11">
                            </OBJECT></LI>
                        </UL>
                    </UL>
                    <LI> <OBJECT type="text/sitemap">
                            <param name="Name" value="g">
                            <param name="Local" value="g.html">
                            <param name="ImageNumber" value="11">
                    </OBJECT></LI>
                </UL>
            </BODY>
        </HTML>
"""
    let testHtml2 = """
        <!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
        <HTML>
            <HEAD>
                <meta name="GENERATOR" content="EasyCHM.exe  www.zipghost.com">
                <!-- Sitemap 1.0 -->
            </HEAD><BODY>
                <OBJECT type="text/site properties">
                    <param name="ExWindow Styles" value="0x200">
                    <param name="Window Styles" value="0x800025">
                    <param name="Font" value="MS Sans Serif,9,0">
                </OBJECT>
                <UL>
                    <LI> <OBJECT type="text/sitemap">
                            <param name="Name" value="a">
                            <param name="Local" value="a.html">
                            <param name="ImageNumber" value="11">
                    </OBJECT></LI>
                    <LI> <OBJECT type="text/sitemap">
                            <param name="Name" value="b">
                            <param name="Local" value="b.html">
                            <param name="ImageNumber" value="1">
                    </OBJECT></LI>
                    <UL>
                        <LI> <OBJECT type="text/sitemap">
                                <param name="Name" value="c">
                                <param name="Local" value="b/c.html">
                                <param name="ImageNumber" value="11">
                        </OBJECT></LI>
                        <LI> <OBJECT type="text/sitemap">
                                <param name="Name" value="specialitem">
                                <param name="Local" value="b/specialitem.html">
                                <param name="ImageNumber" value="1">
                        </OBJECT></LI>
                        <UL>
                            <LI> <OBJECT type="text/sitemap">
                                    <param name="Name" value="e">
                                    <param name="Local" value="b/specialitem/e.html">
                                    <param name="ImageNumber" value="11">
                            </OBJECT></LI>
                        </UL>
                        <UL>
                            <LI> <OBJECT type="text/sitemap">
                                    <param name="Name" value="f">
                                    <param name="Local" value="b/specialitem/f.html">
                                    <param name="ImageNumber" value="11">
                            </OBJECT></LI>
                        </UL>
                    </UL>
                    <LI> <OBJECT type="text/sitemap">
                            <param name="Name" value="g">
                            <param name="Local" value="g.html">
                            <param name="ImageNumber" value="11">
                    </OBJECT></LI>
                </UL>
            </BODY>
        </HTML>
"""
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNormal() throws {
        let data = testHtml1.data(using: .utf8)!
        let res = parseIndex(data)
        assertIndexIsRight(res)
    }
    
    func testNoSlashLI() throws {
        let data = testHtml1.replacingOccurrences(of: "</LI>", with: "").data(using: .utf8)!
        let res = parseIndex(data)
        assertIndexIsRight(res)
    }
    
    func testGB18030() throws {
        let st = "特别"
        let gb_18030_2000 = String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)))
        let data = testHtml1.replacingOccurrences(of: "specialitem", with: st).data(using: gb_18030_2000)!
        let res = parseIndex(data)
        assertIndexIsRight(res, specialItem: st)
    }
    
    func testType2() throws {
        let data = testHtml2.data(using: .utf8)!
        let res = parseIndex(data)
        assertIndexIsRight(res)
    }

    func testPerformance() throws {
        self.measure {
            let data = testHtml1.data(using: .utf8)!
            let res = parseIndex(data)
            assertIndexIsRight(res)
        }
    }
    
    func assertIndexIsRight(_ units: [CHMUnit], specialItem: String = "specialitem") {
        XCTAssertEqual(units.count, 3)
        XCTAssertEqual(units[0].name, "a")
        XCTAssertEqual(units[1].name, "b")
        XCTAssertEqual(units[2].name, "g")
        XCTAssertEqual(units[1].children?.count, 2)
        XCTAssertEqual(units[1].children?[0].name, "c")
        XCTAssertEqual(units[1].children?[1].name, specialItem)
        XCTAssertEqual(units[1].children?[1].children?.count, 2)
        XCTAssertEqual(units[1].children?[1].children?[0].name, "e")
        XCTAssertEqual(units[1].children?[1].children?[1].name, "f")
    }
}
