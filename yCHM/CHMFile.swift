//
//  CHMFile.swift
//  yCHM
//
//  Created by simon xu on 4/22/22.
//

import Foundation

class CHMFile {
    let fd: OpaquePointer
    let items: [CHMUnit]
    let index: [CHMUnit]
    let tree: [CHMUnit]
    
    init(filename: String) {
        fd = chm_open(filename)
        items = listCHMUnit(fd, filter: CHM_ENUMERATE_ALL).0
        let hhcPath = items.first(where: {$0.path.lowercased().hasSuffix(".hhc")})?.path
        // if hhc == nil
        let hhcData = getUrlContent(fd, path: hhcPath!)
        tree = parseIndex(hhcData)
        let hhkPath = items.first(where: {$0.path.lowercased().hasSuffix(".hhk")})?.path
        // if hhk == nil
        let hhkData = getUrlContent(fd, path: hhkPath!)
        index = parseIndex(hhkData)
    }
    
    deinit {
        chm_close(fd)
    }

    func entryPoint () -> CHMUnit {
        var item = tree[0]
        while item.children?[0] != nil {
            item = item.children![0]
        }
        
        return item
    }
    
    func urlCallback(path: String) -> Data {
        return getUrlContent(fd, path: path)
    }
}

func getUrlContent(_ fd: OpaquePointer, path: String) -> Data {
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
        // logger.trace("unit: \(unit.path), \(unit.flagList()), \(unit.length)")
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

