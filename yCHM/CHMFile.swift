//
//  CHMFile.swift
//  yCHM
//
//  Created by simon xu on 4/22/22.
//

import Foundation

class CHMFile {
    let fd: OpaquePointer
    
    init(filename: String) {
        fd = chm_open(filename)
    }
    
    deinit {
        
    }
    
    func first() -> String {
        let buf = UnsafeMutablePointer<UnsafeMutablePointer<UInt8>>.allocate(capacity: 1)
        let type = CHM_ENUMERATE_FILES + CHM_ENUMERATE_NORMAL
        chm_enumerate(fd, type, {(file, item, p) in
            let pres = p!.assumingMemoryBound(to: UnsafeMutablePointer<UInt8>.self)
            let len = item!.pointee.length
            let buf = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(len))
            chm_retrieve_object(file, item, buf, 0, LONGINT64(len))
            pres.pointee = buf
            
            return CHM_ENUMERATOR_SUCCESS
        }, buf)
        
        let res = String(cString: buf.pointee)
        buf.pointee.deallocate()
        return res
    }
}


