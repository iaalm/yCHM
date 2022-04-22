//
//  yCHMApp.swift
//  yCHM
//
//  Created by simon xu on 4/22/22.
//

import SwiftUI

@main
struct yCHMApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView(page: CHMPage(html: "<b>b</b>c"))
        }
    }
}
