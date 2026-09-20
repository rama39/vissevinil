//
//  CaixasContainer.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import SwiftUI
import SwiftData

struct CaixasGridView: View {
    @Environment(\.modelContext) private var modelContext
    func save() { if modelContext.hasChanges { try? modelContext.save() } }
    @Query private var caixas: [CaixaModel]
    
    var body: some View {
        let columns = caixas.count > 3 ?
            [GridItem(.flexible()), GridItem(.flexible())] :
            [GridItem(.flexible())]
        LazyVGrid(columns: columns) {
            ForEach(caixas) { caixa in
                NavigationLink {
                    CaixaView(caixa: caixa)
                } label: {
                    CaixaOuterView(caixa: caixa, count: caixas.count)
                }
                .contextMenu {
                    Button {
                        deleteCaixa(caixa)
                    } label: {
                        Label("Deletar", systemImage: "trash")
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { newCaixa() }
                label: { Image(systemName: "plus") }
            }
        }
    }
    
    private func newCaixa() {
        withAnimation {
            let newCaixa = CaixaModel (
                title: "Nova Caixa",
                rgba: Color.brown.toRGBA )
            modelContext.insert(newCaixa)
            save()
        }
    }
    
    private func deleteCaixa(_ caixa: CaixaModel) {
        withAnimation {
            let deletedCaixa = caixa
//            let pos = deletedDisco.posicao
//            for i in discos.indices {
//                if discos[i].posicao > pos {
//                    discos[i].posicao -= 1
//                }
//            }
            modelContext.delete(deletedCaixa)
            save()
        }
    }
}

#Preview {
    CaixasGridView()
        .modelContainer(for: appSchema, inMemory: true)
}
