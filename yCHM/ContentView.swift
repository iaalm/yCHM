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
    @State var units: [CHMUnit]
    @State var chm: CHMFile? = nil
    
    let docPicker = DocPicker()
    
    var body: some View {
        VStack {
            Button(action: {() in
                let filename = docPicker.display()!
                chm = CHMFile(filename: filename)
                units = chm!.list()
                let unit = units.first(where: {(unit) in
                    unit.path.contains(".html")
                })!
                unitSelected(unit: unit)
            }, label: {
                Text("Open")
            })
            HStack {
                FlatView(items: $units, onClick: self.unitSelected)
                WebView(text: $page.html)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
            
        }
    }
    
    func unitSelected(unit: CHMUnit) {
        print(unit.path)
        self.page.html = chm!.get(unit: unit)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            page: CHMPage(html: "<h1>HTML</h1> content"),
            units: [CHMUnit()]
        )
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
