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
    let onClick: (CHMUnit) -> Void
    
    var body: some View {
        List(items, id: \.id) { unit in
            Button(action: {onClick(unit)}) {
                Text(unit.path)
            }
        }
    }
}

protocol FlatViewController {
    func click(unit: CHMUnit)
}
