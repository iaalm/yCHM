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
        uiView.load(URLRequest(url: URL(string:escapedPath, relativeTo: baseUrl)!))
    }}

class WebViewURLSchemeHandler: NSObject, WKURLSchemeHandler {
    @Binding var location: CHMLocation
    
    init(location: Binding<CHMLocation>) {
        self._location = location
    }
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        print("Function: \(#function), line: \(#line)")
        print("==> \(urlSchemeTask.request.url?.absoluteString ?? "")\n")

        // Your local resource files will be catch here. You can determine it by checking the urlSchemeTask.request.url.
        // From here I will unzip local resource files (js, css, png,...) if they are still in zip format
        let path = urlSchemeTask.request.url!.path
        print("path \(path)")
        let data = self.location.urlCallback(path)

        urlSchemeTask.didReceive(URLResponse(url: urlSchemeTask.request.url!, mimeType: "text/html", expectedContentLength: data.count, textEncodingName: nil))
        urlSchemeTask.didReceive(data)
        urlSchemeTask.didFinish()
    }

    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        print("Function: \(#function), line: \(#line)")
        print("==> \(urlSchemeTask.request.url?.absoluteString ?? "")\n")
    }
}
