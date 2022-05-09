//
//  UnitView.swift
//  yCHM
//
//  Created by simon xu on 4/23/22.
//

import Foundation
import SwiftUI

struct FlatView: View {
    @Binding var items: [CHMUnit]
    let onClick: (CHMUnit) -> Void
    
    var body: some View {
        List(items, id: \.id) { unit in
            UnitView(unit: unit, onClick: onClick)
        }
    }
}

struct TreeView: View {
    @Binding var items: [CHMUnit]
    @Binding var textFilter: String
    let onClick: (CHMUnit) -> Void
    
    var body: some View {
        List(filterByText(query: textFilter, items: items), id: \.id, children: \.children) { unit in
            UnitView(unit: unit, onClick: onClick)
        }
    }
}

struct UnitView: View {
    var unit: CHMUnit
    let onClick: (CHMUnit) -> Void
    
    var body: some View {
        Button(action: { onClick(unit) }) {
            Text(unit.name)
        }.buttonStyle(PlainButtonStyle())
    }

}

func filterByText(query: String, items: [CHMUnit]) -> [CHMUnit]
{
    return items.compactMap({
        if fuzzyMatch(query: query, text: $0.name) {
            return $0
        }
        let filteredChildren = filterByText(query: query, items: $0.children ?? [])
        if filteredChildren.count > 0 {
            return CHMUnit(name: $0.name, path: $0.path, children: filteredChildren)
        }
        return nil
    })
}

func fuzzyMatch(query: String, text: String) -> Bool {
    var idx: String.Index? = text.startIndex
    for i in query {
        idx = text[idx!..<text.endIndex].firstIndex(where: { $0.lowercased() == i.lowercased()})
        if idx == nil {
            return false
        }
        idx = text.index(after: idx!)
    }
    return true
}
