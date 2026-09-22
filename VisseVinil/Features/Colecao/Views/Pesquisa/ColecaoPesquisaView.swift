//
//  ColecaoPesquisaView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 14/09/26.
//

import SwiftUI
import SwiftData

struct ColecaoPesquisaView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var discos: [_DiscoModel]
    
    @State private var bufferBusca = ""
    var discosBuscados: [_DiscoModel] {
        discos.filter { disco in
            if bufferBusca.isEmpty { return true }
            return disco.title
                .localizedCaseInsensitiveContains(bufferBusca)
        }.sorted(by: {
            $0.posicao > $1.posicao
        })
    }
    
    
    var body: some View {
        List {
            ForEach(discosBuscados) { disco in
                NavigationLink {
                    DiscoView(disco: disco)
                } label: {
                    ColecaoPesquisaRow(disco: disco)
                }
            }
            .onDelete(perform: deleteItems)
        }
    }
    
//    private func addItem() {
//        withAnimation {
//            let newDisco = DiscoModel(posicao: discos.count)
//            modelContext.insert(newDisco)
//            let newEvento = EventoModel(.adicionou)
//            newEvento.disco = newDisco
//            modelContext.insert(newEvento)
//        }
//    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(discos[index])
            }
        }
    }
}

#Preview {
    ColecaoPesquisaView()
        .modelContainer(for: appSchema, inMemory: true)
}
