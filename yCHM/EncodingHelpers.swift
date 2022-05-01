//
//  EncodingHelpers.swift
//  yCHM
//
//  Created by simon xu on 4/23/22.
//

import Foundation

let encodingMapping = [
    "gb2312": String.Encoding(rawValue: CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))),
    "ascii": String.Encoding.ascii,
    "utf8": String.Encoding.utf8
]

let encodingList = encodingMapping.map({($0, $1)})

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
    let firstTry = String(data: data, encoding: .ascii)!
    let encodingStr = getEncoding(str: firstTry) ?? "ascii"
    let encoding = encodingMapping[encodingStr]
    if (encoding != nil) {
        return String(data: data, encoding: encoding!)!
    }
    else {
        let guessedEncoding = guessEncoding(data)
        return String(data: data, encoding: encodingMapping[guessedEncoding] ?? .ascii)!
    }
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

func guessEncoding(_ data: Data) -> String {
    let utf8Try = String(data: data, encoding: .utf8) ?? ""
    let encoding = getEncoding(str: utf8Try)
    if encoding != nil {
        return encoding!
    }
    
    let bestGuess = encodingList.map({(e) -> (String, Int) in
        let tryRes = String(data: data, encoding: e.1)
        let wrong = tryRes?.filter({$0 == "\u{fd}"}).count ?? Int.max
        print("Guess \(e.0), \(wrong)")
        return (e.0, wrong)
    })
    .max(by: {$0.1 < $1.1})
    
    print("bestGuess \(bestGuess!.0), \(bestGuess!.1)")
    return bestGuess!.0
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
