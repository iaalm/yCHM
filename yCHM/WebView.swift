//
//  WebView.swift
//  yCHM
//
//  Created by simon xu on 4/27/22.
//

import Foundation
import SwiftUI
import WebKit

struct WebView: NSViewRepresentable {
    @Binding var location: CHMLocation
    let baseUrl = URL(string: "chm://chmhost/")
    func makeNSView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.setURLSchemeHandler(WebViewURLSchemeHandler(location: $location), forURLScheme: "chm")
        return WKWebView(frame: CGRect(), configuration: configuration)
    }

    func updateNSView(_ uiView: WKWebView, context: Context) {
        // uiView.loadHTMLString(text, baseURL: nil)
        let escapedPath = location.path.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        let url = URL(string:escapedPath, relativeTo: baseUrl)
        if url != nil {
            uiView.load(URLRequest(url: url!))
        } else {
            print("invalid path \(location.path)")
        }
    }}

class WebViewURLSchemeHandler: NSObject, WKURLSchemeHandler {
    @Binding var location: CHMLocation
    
    init(location: Binding<CHMLocation>) {
        self._location = location
    }
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        let path = urlSchemeTask.request.url!.path
        print("retrieval \(path)")
        let data = self.location.urlCallback(path)
        let mimeType = guessMimeType(path, data)
        let encodingName: String? = txtMimeTypes.contains(mimeType) ? guessEncoding(data) : nil
        urlSchemeTask.didReceive(URLResponse(url: urlSchemeTask.request.url!, mimeType: mimeType,
                                             expectedContentLength: data.count, textEncodingName: encodingName))
        urlSchemeTask.didReceive(data)
        urlSchemeTask.didFinish()
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        print("stoping \(urlSchemeTask.request.url?.absoluteString ?? "")\n")
    }
}
