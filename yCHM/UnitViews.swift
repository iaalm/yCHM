//
//  UnitView.swift
//  yCHM
//
//  Created by simon xu on 4/23/22.
//

import Foundation
import SwiftUI

class CHMUnitFiltable: CHMUnit, Hashable {
    let allChildren: [CHMUnitFiltable]?
    var filteredChildren: [CHMUnitFiltable]?
    
    init(unit: CHMUnit) {
        allChildren = unit.children?.map({ CHMUnitFiltable(unit: $0) })
        filteredChildren = allChildren
        super.init(unit)
    }
    
    static func == (lhs: CHMUnitFiltable, rhs: CHMUnitFiltable) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct TreeView: View {
    @Binding var items: [CHMUnitFiltable]
    @Binding var textFilter: String
    @Binding var selected: CHMUnitFiltable?
    
    var body: some View {
        List(
            filterByText(query: textFilter, items: items),
            id: \.self, children: \.filteredChildren,
            selection: $selected) { unit in
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

func filterByText(query: String, items: [CHMUnitFiltable]) -> [CHMUnitFiltable]
{
    return items.compactMap({
        if fuzzyMatch(query: query, text: $0.name) {
            return $0
        }
        let filteredChildren = filterByText(query: query, items: $0.allChildren ?? [])
        if filteredChildren.count > 0 {
            $0.filteredChildren = filteredChildren
            return $0
        }
        return nil
    })
}

func fuzzyMatch(query: String, text: String) -> Bool {
    var idx: String.Index? = text.startIndex
    for i in query {
        idx = text[idx!..<text.endIndex]
            .firstIndex(where: { $0.lowercased() == i.lowercased()})
        if idx == nil {
            return false
        }
        idx = text.index(after: idx!)
    }
    return true
}
