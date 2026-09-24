//
//  VisseVinilApp.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import Foundation
import SwiftUI
import SwiftData

let appSchema: [any PersistentModel.Type] = [DiscoModel.self, CaixaModel.self, EventoModel.self, PerfilModel.self]

@main
struct VisseVinilApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema(appSchema)
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
