//
//  CHMUnit.swift
//  yCHM
//
//  Created by simon xu on 4/28/22.
//

import Foundation

class CHMUnit: Identifiable {
    var name: String
    var parent: CHMUnit? = nil
    var children: [CHMUnit]? = nil
    var path: String
    let flags: Int32
    let length: UInt64
    
    init() {
        self.path = ""
        self.name = ""
        self.flags = 0
        self.length = 0
    }
    
    init(path:String, children: [CHMUnit]? = nil) {
        self.flags = 0
        self.path = path
        self.children = children
        self.length = 0
        self.name = getNameFromPath(path)
        children?.forEach({$0.parent = self})
    }
    
    init(name: String, path:String, children: [CHMUnit]? = nil) {
        self.name = name
        self.flags = 0
        self.path = path
        self.children = children
        self.length = 0
        children?.forEach({$0.parent = self})
    }
    
    init(c: UnsafeMutablePointer<chmUnitInfo>?) {
        // crazy tuple mapping convert
        path = withUnsafeBytes(of: c!.pointee.path) { (rawPtr) -> String in
            let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
            return String(cString: ptr)
        }
        
        self.name = getNameFromPath(path)
        flags = c!.pointee.flags
        length = c!.pointee.length
    }
    
    func flagList() -> [String] {
        var res: [String] = []
        [
            (CHM_ENUMERATE_META, "META"),
            (CHM_ENUMERATE_NORMAL, "NORMAL"),
            (CHM_ENUMERATE_SPECIAL, "SPECIAL"),
            (CHM_ENUMERATE_DIRS, "DIRS"),
            (CHM_ENUMERATE_FILES, "FILES"),
        ].forEach({(pair) in
            if (0 != (flags & pair.0)) {
                res.append(pair.1)
            }
        })
        return res
    }
}

extension CHMUnit: Hashable {
    static func == (lhs: CHMUnit, rhs: CHMUnit) -> Bool {
        return lhs.name == rhs.name
            && lhs.path == rhs.path
            && lhs.parent == lhs.parent
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
        hasher.combine(name)
        hasher.combine(parent)
    }
}

func getNameFromPath(_ path: String) -> String {
    let seg = path.split(separator: "/")
    for i in seg.reversed() {
        if i.count > 0 {
            return String(i)
        }
    }
    return "root"
}

extension Array where ArrayLiteralElement: CHMUnit {
    func getRoots() -> [ArrayLiteralElement] {
        return self.filter({ $0.parent == nil})
    }
}
