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

    // Arrastar só faz sentido na ordem manual e com a lista inteira (sem busca)
    private var podeReordenar: Bool {
        ordenacao == .manual && bufferBusca.isEmpty
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
            .onMove(perform: acaoDeMover)
        }
        .toolbar {
            if ordenacao == .manual {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
        }
        // Campo de busca sempre visível (sem precisar puxar a lista pra baixo)
        .searchable(text: $bufferBusca, placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Pesquisar Discos da Coleção")
        // Primeiro disco mais perto da busca (a seção de discos tirados pra ouvir costuma
        // estar vazia e deixava um espaço grande)
        .listSectionSpacing(.compact)
        .contentMargins(.top, 8, for: .scrollContent)
        .alertaGuardar($desRemovendoDisco, addTirouParaOuvir)
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
    
    func addTirouParaOuvir(disco: DiscoModel) {
        
        let newEvento = EventoModel (.tirouParaOuvir)
        let tempoOuvido: Int
        
        if let whenRemoved = disco.whenRemoved {
            tempoOuvido = Calendar .current .dateComponents(
                [.minute], from: whenRemoved, to: Date()
            )
            .minute ?? 0
            newEvento.data = whenRemoved
        } else {
            tempoOuvido = 0
        }
        
        newEvento.disco = disco
        newEvento.comentario = "Ouviu por \(tempoOuvido) minuto\(tempoOuvido > 1 ? "s" : "")"
        
        modelContext.insert(newEvento)
    }
}

#Preview {
    ColecaoPesquisaView()
        .modelContainer(for: appSchema, inMemory: true)
}
