//
//  CHMUnit.swift
//  yCHM
//
//  Created by simon xu on 4/28/22.
//

import Foundation

class CHMUnit: Identifiable {
    var parent: CHMUnit? = nil
    var children: [CHMUnit]? = nil
    let path: String
    let flags: Int32
    let space: Int32
    let start: UInt64
    let length: UInt64
    
    init() {
        self.path = ""
        self.flags = 0
        self.space = 0
        self.start  = 0
        self.length = 0
    }
    
    init(path:String, children: [CHMUnit]? = nil) {
        self.flags = 0
        self.space = 0
        self.start  = 0
        self.length = 0
        self.path = path
        self.children = children
        children?.forEach({$0.parent = self})
    }
    
    init(c: UnsafeMutablePointer<chmUnitInfo>?) {
        // crazy tuple mapping convert
        path = withUnsafeBytes(of: c!.pointee.path) { (rawPtr) -> String in
            let ptr = rawPtr.baseAddress!.assumingMemoryBound(to: CChar.self)
            return String(cString: ptr)
        }
        flags = c!.pointee.flags
        space = c!.pointee.space
        start = c!.pointee.start
        length = c!.pointee.length
    }
    
    var name: String {
        get {
            let seg = path.split(separator: "/")
            for i in seg.reversed() {
                if i.count > 0 {
                    return String(i)
                }
            }
            return "root"
        }
    }
    
    func allocCType() -> UnsafeMutablePointer<chmUnitInfo>{
        let c = UnsafeMutablePointer<chmUnitInfo>.allocate(capacity: 1)
        c.pointee.flags = flags
        c.pointee.space = space
        c.pointee.start = start
        c.pointee.length = length
        // ignore path for now
        
        return c
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

extension Array where ArrayLiteralElement: CHMUnit {
    func getRoots() -> [ArrayLiteralElement] {
        return self.filter({ $0.parent == nil})
    }
}
