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
                let update = CHMFile(filename: filename).first()
                print("prepared")
                DispatchQueue.main.async {
                    print(update)
                    print("update")
                    self.page.html = update
                }
            }, label: {
                /*@START_MENU_TOKEN@*/Text("Button")/*@END_MENU_TOKEN@*/
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
