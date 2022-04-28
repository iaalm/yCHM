//
//  FlatView.swift
//  yCHM
//
//  Created by simon xu on 4/23/22.
//

import Foundation
import SwiftUI

struct FlatView: View {
    @Binding var items: [CHMUnit]
    let onClick: (String) -> Void
    
    var body: some View {
        List(items, id: \.id) { unit in
            UnitView(unit: unit, onClick: onClick)
        }
    }
}

struct TreeView: View {
    @Binding var items: [CHMUnit]
    let onClick: (String) -> Void
    
    var body: some View {
        List(items.filter({ $0.parent == nil }), id: \.id, children: \.children) { unit in
            UnitView(unit: unit, onClick: onClick)
        }
    }
}

struct UnitView: View {
    var unit: CHMUnit
    let onClick: (String) -> Void
    
    var body: some View {
        Button(action: { if unit.length != 0 { onClick(unit.path)}}) {
            Text(unit.name)
        }
    }

}
