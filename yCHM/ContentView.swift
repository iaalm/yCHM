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
    
    @StateObject var index: CHMUnitFiltable = CHMUnitFiltable()
    @StateObject var tree: CHMUnitFiltable = CHMUnitFiltable()
    @StateObject var object: CHMUnitFiltable = CHMUnitFiltable()
    
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
                case .flat: TreeView(items: index, selected: $location.unit)
                case .tree: TreeView(items: tree, selected: $location.unit)
                case .object: TreeView(items: object, selected: $location.unit)
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
            index.load(unit: chm!.index)
            tree.load(unit: chm!.tree)
            object.load(unit: chm!.items)
            location.urlCallback = chm!.urlCallback
            location.unit = CHMUnitFiltable(unit: chm!.entryPoint())
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            location: CHMLocation(),
            tree: CHMUnitFiltable(unit: CHMUnit(path: "/", children: [
                .init(path: "/a/", children: [
                    .init(path: "/a/b"),
                    .init(path: "/a/c")
                ]),
                .init(path: "/d")
            ]))
        )
    }
}

struct CHMLocation {
    var unit: CHMUnitFiltable?
    var urlCallback: (String) -> Data = { _ in logger.trace("Empty URL callback"); return Data()}
}

enum selectorType {
    case flat
    case tree
    case object
}
