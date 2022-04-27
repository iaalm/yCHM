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
            Button(action: {onClick(unit.path)}) {
                Text(unit.path)
            }
        }
    }
}

protocol FlatViewController {
    func click(path: String)
}
