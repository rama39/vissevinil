//
//  ContentView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Explorar", systemImage: "eye") {
                ExplorarView()
            }
            Tab("Coleção", systemImage: "square.stack") {
                ListaDiscosView()
            }
            Tab("Mapa", systemImage: "map") {
                MapaView()
            }
            Tab("Perfil", systemImage: "person") {
                PerfilView()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: appSchema, inMemory: true)
}
