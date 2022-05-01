//
//  EncodingHelpers.swift
//  yCHM
//
//  Created by simon xu on 4/23/22.
//

import Foundation

let extensionMimeMapping = [
    "html": "text/html",
    "htm": "text/html",
    "jpeg": "image/jpeg",
    "jpg": "image/jpeg"
]

func decodeString(ptr: UnsafeMutablePointer<UInt8>, len: Int) -> String {
    return decodeString(data: Data(bytes: ptr, count: len))
}

func decodeString(data: Data) -> String {
    var convertedString: NSString?
    let encoding = NSString.stringEncoding(for: data, encodingOptions: nil, convertedString: &convertedString, usedLossyConversion: nil)
    print(encodingToTextName(encoding)!)
    return convertedString! as String
}

func getEncoding(str: String) -> String? {
    let validChar = "abcderghijklmnopqrstuvwxyz0123456789"
    let startIdx = str.range(of: "charset=")?.upperBound
    if startIdx == nil {
        return nil
    }
    let encodingStart = str.suffix(from: startIdx!)
    let encoding = encodingStart.prefix(while: {validChar.lowercased().contains($0)})
    
    return String(encoding)
}

func guessEncoding(_ data: Data) -> String? {
    var convertedString: NSString?
    let encoding = NSString.stringEncoding(for: data, encodingOptions: nil, convertedString: &convertedString, usedLossyConversion: nil)
    return encodingToTextName(encoding)
}

func encodingToTextName(_ encoding: UInt) -> String? {
    let cfEnc = CFStringConvertNSStringEncodingToEncoding(encoding)
    return CFStringConvertEncodingToIANACharSetName(cfEnc) as String?
}


func guessMimeType(_ filename: String, _ data: Data) -> String {
    let extName = String(
        filename.suffix(
            from: filename.index(
                filename.lastIndex(of: ".")
                ?? filename.startIndex, offsetBy: 1 )))
    let mimeType = extensionMimeMapping[extName]
    if mimeType != nil {
        return mimeType!
    }
    
    return "text/html"
}
