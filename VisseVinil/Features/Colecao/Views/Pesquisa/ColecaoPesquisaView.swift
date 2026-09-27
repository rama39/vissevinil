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
            bufferBusca.isEmpty ||
            disco.title.localizedCaseInsensitiveContains(bufferBusca)
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
        .searchable(text: $bufferBusca, prompt: "Pesquisar Discos da Coleção")
        .alertaGuardar($desRemovendoDisco)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let deletado = discosBuscados[index]
                for disco in discos {
                    if disco.posicao > deletado.posicao {
                        disco.posicao -= 1
                    }
                }
                modelContext.delete(deletado)
            }
        }
    }
}

#Preview {
    ColecaoPesquisaView()
        .modelContainer(for: appSchema, inMemory: true)
}
