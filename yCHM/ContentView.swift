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
    @State var chm: CHMFile? = nil
    @State var selector: selectorType = .tree
    
    @State var index: [CHMUnit] = []
    @State var tree: [CHMUnit] = []
    @State var object: [CHMUnit] = []
    
    let docPicker = DocPicker()
    
    var body: some View {
        HStack {
            VStack {
                HStack {
                    Button(action: {() in
                        selector = .tree
                    }, label: {
                        Text("Tree")
                    }).disabled(selector == .tree)
                    Button(action: {() in
                        selector = .flat
                    }, label: {
                        Text("Index")
                    }).disabled(selector == .flat)
                    Button(action: {() in
                        selector = .object
                    }, label: {
                        Text("Obj")
                    }).disabled(selector == .object)
                }
                switch selector {
                case .flat: TreeView(items: $index, onClick: self.unitSelected)
                case .tree: TreeView(items: $tree, onClick: self.unitSelected)
                case .object: TreeView(items: $object, onClick: self.unitSelected)
                }
            }
            .frame(minWidth: 100, idealWidth: 200, maxWidth: 200, minHeight: /*@START_MENU_TOKEN@*/0/*@END_MENU_TOKEN@*/, idealHeight: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.top, 5)
            
            WebView(location: $location)
            .toolbar {
                ToolbarItemGroup(placement: .navigation) {
                    Button(action: {() in
                        fileOpened(docPicker.display())
                    }, label: {
                        Text("Open")
                    })
                }
            }
        }
    }
    
    func fileOpened(_ filename: String?) {
        if filename != nil {
            chm = CHMFile(filename: filename!)
            index = chm!.index
            tree = chm!.tree
            object = chm!.items
            unitSelected(unit: chm!.entryPoint())
        }
    }
    
    func unitSelected(unit: CHMUnit) {
        logger.debug("Select \(unit.name), \(unit.path)")
        self.location = CHMLocation(path: unit.path, urlCallback: chm!.urlCallback)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            location: CHMLocation(path: "/index.html"),
            tree: [CHMUnit(path: "/", children: [
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
    var urlCallback: (String) -> Data = { _ in logger.trace("Empty URL callback"); return Data()}
}

enum selectorType {
    case flat
    case tree
    case object
}
