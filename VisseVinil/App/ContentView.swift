//
//  ContentView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import SwiftUI
import SwiftData

enum VisseVinilTabs {
    case mapa
    case buscar
    case colecao
    case perfil
}

struct ContentView: View {
    @State private var tabSelecionada: VisseVinilTabs = .colecao
    var body: some View {
        TabView(selection: $tabSelecionada) {
            Tab("Mapa", systemImage: "map", value: .mapa) {
                MapaView()
            }
            Tab("Buscar", systemImage: "magnifyingglass", value: .buscar) {
                BuscarView()
            }
            Tab("Coleção", systemImage: "music.note.square.stack.fill", value: .colecao) {
                ColecaoView()
            }
            Tab("Perfil", systemImage: "person", value: .perfil) {
                PerfilView()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: appSchema, inMemory: true)
}
