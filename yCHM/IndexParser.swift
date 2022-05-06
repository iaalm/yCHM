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
        return parseDir(element: doc.body()!).children ?? []
    } catch {
        print("parse error")
        return []
    }
}

func parseDir(element: Element, parent: CHMUnit? = nil) -> CHMUnit {
    let unit = CHMUnit()
    unit.name = "directory"
    for i in element.children() {
        switch i.tagName(){
        case "object":
            for j in i.children() {
                switch j.tagName(){
                case "param":
                    do {
                        let pName = try j.attr("name")
                        switch pName {
                        case "Name":
                            unit.name = try j.attr("value")
                        case "Local":
                            let path = try j.attr("value")
                            unit.path = path.starts(with: "/") ? path : "/" + path
                        case "ImageNumber":
                            // TODO: figure out what "ImageNumber" means
                            break
                        case "Font":
                            break
                        case "ExWindow Styles":
                            break
                        case "Window Styles":
                            break
                        default:
                            print("unknown param \(pName)")
                        }
                    } catch {
                        print("get html error")
                    }
                default:
                    print("unknown object tag \(j.tagName())")
                }
            }
        case "ul":
            unit.children = []
            for j in i.children() {
                unit.children!.append(parseDir(element: j, parent: unit))
            }
        default:
            print("unknown item tag \(getDomPath(i))")
        }
    }
    return unit
}

func getDomPath(_ element: Element?) -> String {
    var e = element
    var res = ""
    while e != nil {
        res = ">" + e!.tagName() + res
        e = e!.parent()
    }
    return res
}
