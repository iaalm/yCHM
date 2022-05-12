//
//  UnitView.swift
//  yCHM
//
//  Created by simon xu on 4/23/22.
//

import Foundation
import SwiftUI

struct TreeView: View {
    @Binding var items: [CHMUnit]
    @Binding var textFilter: String
    @Binding var selected: CHMUnit?
    
    var body: some View {
        List(filterByText(query: textFilter, items: items), id: \.self, children: \.children, selection: $selected) { unit in
            UnitView(unit: unit)
        }
    }
}

struct UnitView: View {
    var unit: CHMUnit
    
    var body: some View {
        Text(unit.name)
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
