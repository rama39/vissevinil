//
//  ColecaoPesquisaView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 14/09/26.
//

import SwiftUI
import SwiftData

//TODO: rename to ColecaoDiscosView e ColecaoDiscosRow
struct ColecaoPesquisaView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var discos: [DiscoModel]
    
    @State private var bufferBusca = ""
    var discosBuscados: [DiscoModel] {
        discos.filter { disco in
            if bufferBusca.isEmpty { return true }
            return disco.title
                .localizedCaseInsensitiveContains(bufferBusca)
        }.sorted(by: {
            $0.posicao > $1.posicao
        })
    }
    
    @State var desRemovendoDisco: DiscoModel? = nil
    
    var body: some View {
        List {
            Section {
                DiscosRemovidosView(desRemovendoDisco: $desRemovendoDisco)
            }
            ForEach(discosBuscados) { disco in
                NavigationLink {
                    DiscoView(disco: disco)
                } label: {
                    ColecaoPesquisaRow(disco: disco)
                }
            }
            .onDelete(perform: deleteItems)
        }
        .alert("Guardar Disco", item: $desRemovendoDisco) { disco in
            // TODO: MAKE BLUE
            Button("Guardar disco na frente", role: .confirm) {
                withAnimation {
                    // TODO: mover à frente
                    disco.removed = false
                    desRemovendoDisco = nil
                }
            }
            Button("Guardar disco onde estava", role: .none) {
                withAnimation {
                    disco.removed = false
                    desRemovendoDisco = nil
                }
            }
            Button("Cancelar", role: .cancel) {
                desRemovendoDisco = nil
            }
        } message: { _ in
            if let disco = desRemovendoDisco {
                let text = "Disco: \(disco.title) - \(disco.artistsListed)" + (disco.caixa != nil ?
                    "\nCaixa: \(disco.caixa!.title)" : "")
                Text(text)
            }
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
