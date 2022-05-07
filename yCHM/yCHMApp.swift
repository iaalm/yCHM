//
//  yCHMApp.swift
//  yCHM
//
//  Created by simon xu on 4/22/22.
//

import SwiftUI
import Logging

let logger = Logger(label: "cn.iaalm.yCHM")

@main
struct yCHMApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView(
                location: CHMLocation(path: "/"))
        }
    }
}
