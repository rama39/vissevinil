//
//  ListaDiscosView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import SwiftUI
import SwiftData

struct ListaDiscosView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var discos: [Disco]
    
    @State private var bufferBusca = ""
    var discosBuscados: [Disco] {
        discos.filter { disco in
            if bufferBusca.isEmpty { return true }
            return disco.nome
                .localizedCaseInsensitiveContains(bufferBusca)
        }.sorted(by: {
            $0.posicao > $1.posicao
        })
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(discosBuscados) { disco in
                    NavigationLink {
                        Text("Disco \(disco.nome)")
                    } label: {
                        Text("\(disco.nome)")
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newDisco = Disco(posicao: discos.count)
            modelContext.insert(newDisco)
            let newEvento = Evento(.adicionou)
            newEvento.disco = newDisco
            modelContext.insert(newEvento)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(discos[index])
            }
        }
    }
}

#Preview {
    ListaDiscosView()
        .modelContainer(for: appSchema, inMemory: true)
}
