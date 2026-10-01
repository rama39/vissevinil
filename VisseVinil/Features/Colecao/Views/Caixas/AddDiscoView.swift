//
//  AddDiscoView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 20/09/26.
//

import SwiftUI
import SwiftData

struct AddDiscoView: View {
    @Environment(\.modelContext) private var modelContext
    func save() { if modelContext.hasChanges { try? modelContext.save() } }
    @Query private var discos: [DiscoModel]
    
    @Bindable var caixa: CaixaModel
    @Binding var adicionandoDisco: Bool
    
    @State private var bufferBusca = ""
    var discosBuscados: [DiscoModel] {
        discos.filter { disco in
            bufferBusca.isEmpty ||
            disco.title.localizedCaseInsensitiveContains(bufferBusca)
        }
        .sorted(by: {
            $0.posicao > $1.posicao
        })
        .filter({$0.caixa == nil})
    }
    
    var body: some View {
        NavigationStack {
            List(discosBuscados) {disco in
                let contains = caixa.discos.contains(disco)
                if !contains {
                    Button {
                        var count = caixa.discos.count
                        if caixa.discos.map({$0.posicao}).contains(count) {
                            count += 1
                        }
                        disco.posicaoCaixa = (caixa.discos.compactMap(\.posicaoCaixa).max() ?? -1) + 1
                        disco.adicionadoNaCaixaEm = .now
                        disco.caixa = caixa
                        save()
                        adicionandoDisco = false
                    } label: {
                        ColecaoPesquisaRow(disco: disco)
                    }
                }
            }
            .navigationTitle("Adicionar Disco da Coleção")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $bufferBusca, prompt: "Pesquisar Discos da Coleção")
        }
    }
}

//#Preview {
//    AddDiscoView()
//}
