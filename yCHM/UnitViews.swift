//
//  UnitView.swift
//  yCHM
//
//  Created by simon xu on 4/23/22.
//

import Foundation
import SwiftUI

class CHMUnitFiltable: CHMUnit, Hashable, ObservableObject {
    var allChildren: [CHMUnitFiltable]? = []
    @Published var filteredChildren: [CHMUnitFiltable]? = []
    var lastfilter: String = ""

    override init() {
        super.init()
    }
    
    init(unit: CHMUnit) {
        allChildren = unit.children?.map({ CHMUnitFiltable(unit: $0) })
        filteredChildren = allChildren
        super.init(unit)
    }
    
    func load(unit: CHMUnit) {
        name = unit.name
        path = unit.path
        parent = unit.parent
        children = unit.children
        allChildren = unit.children?.map({ CHMUnitFiltable(unit: $0) })
        filteredChildren = allChildren
    }
    
    func filter(text: String) -> CHMUnitFiltable {
        if lastfilter == text {
            // urgely but break the update loop
            return self
        }
        self.filteredChildren = allChildren?.filter({
            if fuzzyMatch(query: text, text: $0.name) {
                return true
            }
            var _ = $0.filter(text: text)
            if ($0.filteredChildren?.count ?? -1) > 0 {
                return true
            }
            return false
        })
        lastfilter = text
        return self
    }
    
    static func == (lhs: CHMUnitFiltable, rhs: CHMUnitFiltable) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct TreeView: View {
    @ObservedObject var items: CHMUnitFiltable
    @Binding var textFilter: String
    @Binding var selected: CHMUnitFiltable?
    
    var body: some View {
        List(
            items.filter(text: textFilter).filteredChildren!,
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
