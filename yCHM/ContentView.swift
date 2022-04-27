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
    // TODO: replace to CHM unit to a better object with key and tree support
    @State var units: [CHMUnit]
    @State var chm: CHMFile? = nil
    
    let docPicker = DocPicker()
    
    var body: some View {
        VStack {
            Button(action: {() in
                let filename = docPicker.display()!
                chm = CHMFile(filename: filename)
                units = chm!.list()
                unitSelected(path: chm!.entryPoint())
            }, label: {
                Text("Open")
            })
            HStack {
                FlatView(items: $units, onClick: self.unitSelected)
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
            units: [CHMUnit()]
        )
    }
}
    
struct CHMLocation {
    var path: String
    var urlCallback: (String) -> Data = { _ in print("Empty URL callback"); return Data()}
}
