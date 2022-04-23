//
//  EncodingHelpers.swift
//  yCHM
//
//  Created by simon xu on 4/23/22.
//

import Foundation

func decodeString(ptr: UnsafeMutablePointer<UInt8>, len: Int) -> String {
    let encodingMapping = [
        "gb2312": String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue)))
    ]
    let firstTry = String(cString: ptr)
    let encodingStr = getEncoding(str: firstTry)
    let encoding = encodingMapping[encodingStr]
    if (encoding.hashValue != 0) {
        return String(data: Data(bytes: ptr, count: len), encoding: encoding!)!
    }
    else {
        return firstTry
    }
}

func getEncoding(str: String) -> String {
    let validChar = "abcderghijklmnopqrstuvwxyz0123456789"
    let startIdx = str.range(of: "charset=")!.upperBound
    let encodingStart = str.suffix(from: startIdx)
    let encoding = encodingStart.prefix(while: {validChar.lowercased().contains($0)})
    
    return String(encoding)
}
