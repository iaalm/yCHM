//
//  CHMFile.swift
//  yCHM
//
//  Created by simon xu on 4/22/22.
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


class CHMFile {
    let fd: OpaquePointer
    var path_mapping: Dictionary<String, CHMUnit>
    let pages: [CHMUnit]
    
    init(filename: String) {
        fd = chm_open(filename)
        path_mapping = Dictionary<String, CHMUnit>()
        var len: Int = 0
        let filter = CHM_ENUMERATE_NORMAL + CHM_ENUMERATE_FILES + CHM_ENUMERATE_DIRS
        chm_enumerate(fd, filter, {(file, item, p) in
            let pres = p!.assumingMemoryBound(to: Int.self)
            pres.pointee += 1
            return CHM_ENUMERATOR_CONTINUE
        }, &len)
        var res = ([CHMUnit](repeating: CHMUnit(), count: len), 0)
        chm_enumerate(fd, filter, {(file, item, p) in
            let pres = p!.assumingMemoryBound(to: ([CHMUnit], Int).self)
            let unit = CHMUnit(c: item)
            print("unit: \(unit.path), \(unit.flagList()), \(unit.length)")
            pres.pointee.0[pres.pointee.1] = unit
            pres.pointee.1 += 1
            
            return CHM_ENUMERATOR_CONTINUE
        }, &res)
        
        let items = res.0
        for i in items {
            path_mapping[i.path] = i
        }
        
        for i in items {
            let path = i.path.prefix(i.path.count - 1)
            let idx = path.lastIndex(of: "/")
            if idx == nil {
                continue
            }
            let ppath = String(i.path.prefix(through: idx!))
            path_mapping[ppath] = path_mapping[ppath] ?? CHMUnit()
            path_mapping[ppath]!.children = path_mapping[ppath]!.children ?? []
            path_mapping[ppath]!.children!.append(i)
            i.parent = path_mapping[ppath]
        }
        
        pages = items
    }
    
    deinit {
        chm_close(fd)
    }
    
    func list() -> [CHMUnit] {
        return pages
    }
    
    func getPageTree() -> CHMUnit {
        return pages[0]
    }
//
//    func first() -> String {
//        let buf = UnsafeMutablePointer<UnsafeMutablePointer<UInt8>>.allocate(capacity: 1)
//        let type = CHM_ENUMERATE_FILES + CHM_ENUMERATE_NORMAL
//        chm_enumerate(fd, type, {(file, item, p) in
//            let pres = p!.assumingMemoryBound(to: UnsafeMutablePointer<UInt8>.self)
//            let len = item!.pointee.length
//            let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(len))
//            chm_retrieve_object(file, item, buf, 0, LONGINT64(len))
//            pres.pointee = buf
//
//            return CHM_ENUMERATOR_SUCCESS
//        }, buf)
//
//        let res = decodeString(ptr: buf.pointee)
//        buf.pointee.deallocate()
//        return res
//    }
    
    func get(unit: CHMUnit) -> String {
        let ui = unit.allocCType()
        let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(unit.length))
        chm_retrieve_object(fd, ui, buf, 0, LONGINT64(unit.length))
        // TODO: maybe remove this function along with Encoding helpers
        let res = decodeString(ptr: buf, len: Int(unit.length))
        buf.deallocate()
        
        return res
    }
    
    func entryPoint () -> String {
        let units = self.list()
        let unit = units.first(where: {(unit) in
            unit.path.contains(".html")
        })!
        return unit.path
    }
    
    func urlCallback(path: String) -> Data {
        print("Getting \(path)")
        let unit = UnsafeMutablePointer<chmUnitInfo>.allocate(capacity: 1)
        unit.pointee.start = 0
        unit.pointee.length = 0
        let pathPtr = UnsafePointer<CChar>((path as NSString).utf8String)
        chm_resolve_object(fd, pathPtr, unit)
        if unit.pointee.length == 0 {
            // no content
            return Data()
        }
        let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(unit.pointee.length))
        chm_retrieve_object(fd, unit, buf, 0, LONGINT64(unit.pointee.length))
        
        // use no copy here
        let res = Data(bytes: buf, count: Int(unit.pointee.length))
        buf.deallocate()
        unit.deallocate()
        return res
    }
}


