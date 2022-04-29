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
    @State var location: CHMLocation
    @State var units: [CHMUnit]
    @State var chm: CHMFile? = nil
    @State var selector: selectorType = .tree
    
    let docPicker = DocPicker()
    
    var body: some View {
        VStack {
            HStack {
                Button(action: {() in
                    let filename = docPicker.display()!
                    chm = CHMFile(filename: filename)
                    units = chm?.pages ?? []
                    unitSelected(path: chm!.entryPoint())
                }, label: {
                    Text("Open")
                })
            }
            HStack {
                VStack {
                    HStack {
                        Button(action: {() in
                            selector = .flat
                            units = chm?.pages ?? []
                        }, label: {
                            Text("flat")
                        })
                        Button(action: {() in selector = .tree
                            units = chm?.items ?? []
                        }, label: {
                            Text("tree")
                        })
                        Button(action: {() in selector = .tree
                            units = chm?.pages ?? []
                        }, label: {
                            Text("html")
                        })
                    }
                    switch selector {
                    case .flat: FlatView(items: $units, onClick: self.unitSelected)
                    case .tree: TreeView(items: $units, onClick: self.unitSelected)
                    }
                }.frame(minWidth: 100, idealWidth: 200, maxWidth: 200, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: .infinity, maxHeight: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                
                
                WebView(location: $location)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            }
            
        }
    }
    
    func unitSelected(path: String) {
        print(path)
        self.location = CHMLocation(path: path, urlCallback: chm!.urlCallback)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            location: CHMLocation(path: "/index.html"),
            units: [CHMUnit(path: "/", children: [
                .init(path: "/a/", children: [
                    .init(path: "/a/b"),
                    .init(path: "/a/c")
                ]),
                .init(path: "/d")
            ])]
        )
    }
}
    
struct CHMLocation {
    var path: String
    var urlCallback: (String) -> Data = { _ in print("Empty URL callback"); return Data()}
}

enum selectorType {
    case flat
    case tree
}
