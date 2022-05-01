//
//  IndexParser.swift
//  yCHM
//
//  Created by simon xu on 4/30/22.
//

import Foundation
import SwiftSoup

func parseIndex(_ data: Data) -> [CHMUnit] {
    let htmlStr = decodeString(data: data)
    do {
        let doc = try SwiftSoup.parse(htmlStr)
        return [parseObject(element: doc.body()!)]
    } catch {
        print("parse error")
        return []
    }
}

func parseObject(element: Element, parent: CHMUnit? = nil) -> CHMUnit {
    let unit = CHMUnit()
    unit.children = []
    for i in element.children() {
        switch i.tagName(){
        case "param":
            do {
                let pName = try i.attr("name")
                switch pName {
                case "Name":
                    unit.name = try i.attr("value")
                case "Local":
                    unit.path = try i.attr("value")
                default:
                    print("unknown param \(pName)")
                }
            } catch {
                print("get html error")
            }
        case "ul":
            for li in i.children() {
                if li.children().count != 1 {
                    print("li children count \(li.children().count)")
                }
                unit.children?.append(parseObject(element: li.child(0), parent: unit))
            }
        default:
            print("unknown tag \(i.tagName())")
        }
    }
    return unit
}
