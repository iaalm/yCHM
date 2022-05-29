//
//  IndexParser.swift
//  yCHM
//
//  Created by simon xu on 4/30/22.
//

import Foundation
import SwiftSoup

func parseIndex(_ data: Data) -> CHMUnit {
    let htmlStr = decodeString(data: data)
    do {
        let doc = try SwiftSoup.parse(htmlStr)
        return parseBody(doc.body()!)
    } catch {
        logger.error("parse error")
        return CHMUnit()
    }
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

func parseObj(_ element: Element) -> CHMUnit {
    let unit = CHMUnit()
    for i in element.children() {
        switch i.tagName(){
        case "param":
            do {
                let pName = try i.attr("name")
                switch pName {
                case "Name":
                    unit.name = try i.attr("value")
                case "Local":
                    let path = try i.attr("value")
                    unit.path = path.starts(with: "/") ? path : "/" + path
                case "ImageNumber":
                    // TODO: figure out what "ImageNumber" means
                    break
                case "See Also":
                    break
                default:
                    logger.warning("unknown param \(pName)")
                }
            } catch {
                logger.error("get property error")
            }
        default:
            break
        }
    }
    return unit
}

func parseUL(_ element: Element) -> [CHMUnit] {
    var res: [CHMUnit] = []
    for i in element.children() {
        switch i.tagName() {
        case "li":
            let u = parseLI(i)
            let uc = u.children
            if uc == nil {
                res.append(u)
            } else {
                // misplaced ul
                let others = uc![1..<uc!.count]
                u.children = uc![0].children
                res.append(u)
                res += others
            }
        case "ul":
            let lastIdx = res.count - 1
            if lastIdx == -1 {
                logger.error("ul after nothing")
            }
            if res[lastIdx].children == nil {
                res[lastIdx].children = parseUL(i)
            } else {
                res[lastIdx].children! += parseUL(i)
            }
        default:
            logger.warning("Unknown tag \(#function) \(getDomPath(i))")
        }
    }
    return res
}

func parseLI(_ element: Element) -> CHMUnit {
    var res = CHMUnit()
    for i in element.children() {
        switch i.tagName() {
        case "ul":
            // misplaced ul
            res.children = res.children ?? []
            let u = CHMUnit()
            u.children = parseUL(i)
            res.children!.append(u)
        case "object":
            res = parseObj(i)
        default:
            logger.warning("Unknown tag \(#function) \(getDomPath(i))")
        }
    }
    return res
}

func parseBody(_ element: Element) -> CHMUnit {
    let res = CHMUnit()
    for i in element.children() {
        switch i.tagName() {
        case "ul":
            if res.children != nil {
                logger.warning("multi ul found for body")
            }
            res.children = parseUL(i)
        case "object":
            break
        default:
            logger.error("Unknown tag \(#function) \(getDomPath(i))")
        }
    }
    return res
}
