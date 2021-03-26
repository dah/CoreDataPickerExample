//
//  CoreDataPickerExampleApp.swift
//  CoreDataPickerExample
//
//  Created by Dan Hancu on 26/03/2021.
//

import SwiftUI

@main
struct CoreDataPickerExampleApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
