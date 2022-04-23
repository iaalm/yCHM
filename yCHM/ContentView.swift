//
//  ContentView.swift
//  yCHM
//
//  Created by simon xu on 4/22/22.
//

import SwiftUI
import WebKit
import CoreData

struct ContentView: View {
    @State var page: CHMPage
    
    let docPicker = DocPicker()
    
    var body: some View {
        VStack
        {
            Button(action: {() in
                let filename = docPicker.display()!
                let chm = CHMFile(filename: filename)
                let unit = chm.list().first(where: {(unit) in
                    unit.path.contains(".html")
                })!
                print(unit.path)
            self.page.html = chm.get(unit: unit)
            }, label: {
                Text("Open")
            })
            WebView(text: $page.html)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(page: CHMPage(html: "a<b>b</b>"))
    }
}
    

struct WebView: NSViewRepresentable {
  @Binding var text: String
   
  func makeNSView(context: Context) -> WKWebView {
    return WKWebView()
  }
   
  func updateNSView(_ uiView: WKWebView, context: Context) {
    uiView.loadHTMLString(text, baseURL: nil)
  }
}

struct CHMPage {
    var html: String
}
