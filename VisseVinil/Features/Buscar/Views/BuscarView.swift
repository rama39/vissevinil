//
//  InicioView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import SwiftUI
import SwiftData

struct BuscarView: View {
    var body: some View {
        PesquisaGlobalView()
    }
}

#Preview {
    TabView {
        Tab("Buscar", systemImage: "magnifyingglass") {
            BuscarView()
                .modelContainer(for: appSchema, inMemory: true)
        }
    }
}
