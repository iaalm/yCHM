//
//  EncodingHelpers.swift
//  yCHM
//
//  Created by simon xu on 4/23/22.
//

import Foundation

let extensionMimeMapping = [
    "html": "text/html",
    "htm":  "text/html",
    "css":  "text/css",
    "gif":  "image/gif",
    "jpg":  "image/jpeg",
    "jpeg": "image/jpeg",
    "jpe":  "image/jpeg",
    "bmp":  "image/bitmap",
    "png":  "image/png"
]

let txtMimeTypes = [
    "text/css",
    "text/html"
]

func decodeString(ptr: UnsafeMutablePointer<UInt8>, len: Int) -> String {
    return decodeString(data: Data(bytes: ptr, count: len))
}

func decodeString(data: Data) -> String {
    var convertedString: NSString?
    // 11 means windows-1251 which cause some issue for chinese
    let encodingOpt: [StringEncodingDetectionOptionsKey : [NSNumber]]  = [.disallowedEncodingsKey: [11]]
    var lossy: ObjCBool = true
    let encoding = NSString.stringEncoding(for: data, encodingOptions: encodingOpt, convertedString: &convertedString, usedLossyConversion: &lossy)
    print("get \(encodingToTextName(encoding)!) (\(encoding)) lossy \(lossy)")
    if lossy.boolValue == true {
        let encoding_all = NSString.stringEncoding(for: data, encodingOptions: encodingOpt, convertedString: &convertedString, usedLossyConversion: &lossy)
        print("use \(encodingToTextName(encoding_all)!) (\(encoding)) lossy \(lossy)")
        
    }
    return convertedString! as String
}

func getEncoding(str: String) -> String? {
    let validChar = "abcderghijklmnopqrstuvwxyz0123456789-"
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
