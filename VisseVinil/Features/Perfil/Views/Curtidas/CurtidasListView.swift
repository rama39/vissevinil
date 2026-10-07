//
//  CurtidasListView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 01/10/26.
//

import SwiftUI
import SwiftData

struct CurtidasListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var curtidas: [CurtidaModel]

    @State private var bufferBusca = ""
    // Busca pelo título ou pelo artista
    private var curtidasBuscadas: [CurtidaModel] {
        guard !bufferBusca.isEmpty else { return curtidas }
        return curtidas.filter { curtida in
            (curtida.master_title ?? "").localizedCaseInsensitiveContains(bufferBusca) ||
            (curtida.artists ?? []).contains { ($0.name ?? "").localizedCaseInsensitiveContains(bufferBusca) }
        }
    }

    var body: some View {
        List {
            ForEach(curtidasBuscadas) { curtida in //search filters for master vinyl versions
                NavigationLink {
                    MasterView(master_id: curtida.master_id ?? 0)
                } label: {
                    CurtidaRow(curtida: curtida)
                }
            }
            
            .onDelete(perform: deleteItems)
        }
        // Igual a "Meus Discos": busca sempre visível e o primeiro disco perto dela
        .searchable(text: $bufferBusca, placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Pesquisar Discos Curtidos")
        .listSectionSpacing(.compact)
        .contentMargins(.top, 8, for: .scrollContent)
        .overlay {
            if !bufferBusca.isEmpty && curtidasBuscadas.isEmpty {
                ContentUnavailableView.search(text: bufferBusca)
            }
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            // Índices da lista exibida (pode estar filtrada pela busca)
            let lista = curtidasBuscadas
            for index in offsets {
                let deletado = lista[index]
                modelContext.delete(deletado)
            }
        }
    }
}
//
//#Preview {
//    CurtidasListView()
//}
