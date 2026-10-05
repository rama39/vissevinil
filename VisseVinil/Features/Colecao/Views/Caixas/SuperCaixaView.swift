//
//  SuperCaixaView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 05/10/26.
//

import SwiftUI
import SwiftData

struct SuperCaixaView: View {
    @Environment(\.modelContext) private var modelContext
    func save() { if modelContext.hasChanges { try? modelContext.save() } }
    
    @Query private var discos: [DiscoModel]
    
    // Mesmas chaves do menu "Ordenar Por" da ColecaoView
    @AppStorage("colecao.ordenacao") private var ordenacao: Ordenacao = .inclusao
    @AppStorage("colecao.ordemCrescente") private var ordemCrescente = false

    @State private var bufferBusca = ""
    var discosBuscados: [DiscoModel] {
        discos.filter { disco in
            bufferBusca.isEmpty ||
            disco.title.localizedCaseInsensitiveContains(bufferBusca)
        }
        .ordenados(por: ordenacao, crescente: ordemCrescente, em: .colecao)
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
            .onMove(perform: acaoDeMover)
        }
        .navigationTitle("Todos os Discos")
        .toolbar {
            if ordenacao == .manual {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
        .searchable(text: $bufferBusca, prompt: "Pesquisar Discos da Coleção")
    }
    
    
    
    // Arrastar só faz sentido na ordem manual e com a lista inteira (sem busca)
    private var podeReordenar: Bool {
        ordenacao == .manual && bufferBusca.isEmpty
    }

    // nil desliga o arrastar (a lista só deixa mover quando há uma ação)
    private var acaoDeMover: ((IndexSet, Int) -> Void)? {
        guard podeReordenar else { return nil }
        return { origem, destino in moverDiscos(de: origem, para: destino) }
    }

    // Salva a nova ordem como ordem manual (o app lembra onde cada disco está)
    private func moverDiscos(de origem: IndexSet, para destino: Int) {
        var lista = discosBuscados
        lista.move(fromOffsets: origem, toOffset: destino)
        lista.salvarComoOrdemManual(em: .colecao)
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
