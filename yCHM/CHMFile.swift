//
//  CHMFile.swift
//  yCHM
//
//  Created by simon xu on 4/22/22.
//

import Foundation

class CHMFile {
    let fd: OpaquePointer
    let path_mapping: Dictionary<String, CHMUnit>
    // pages may not needed in future, use it before has toc feature
    let pages: [CHMUnit]
    let items: [CHMUnit]
    
    init(filename: String) {
        fd = chm_open(filename)
        let limited = listCHMUnit(fd, filter: CHM_ENUMERATE_NORMAL + CHM_ENUMERATE_FILES + CHM_ENUMERATE_DIRS)
        pages = limited.0
        path_mapping = limited.1
        items = listCHMUnit(fd, filter: CHM_ENUMERATE_ALL).0
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

func listCHMUnit(_ fd: OpaquePointer, filter: Int32) -> ([CHMUnit], Dictionary<String, CHMUnit>) {
    var path_mapping = Dictionary<String, CHMUnit>()
    var len: Int = 0
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
    
    return (items, path_mapping)
}


