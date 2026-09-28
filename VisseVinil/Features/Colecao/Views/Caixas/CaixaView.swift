//
//  CaixaView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import SwiftUI

struct CaixaView: View {
    
    @Bindable var caixa: CaixaModel
    
    @State private var bufferBusca = ""
    var discosBuscados: [DiscoModel] {
        caixa.discos
        .filter { disco in
            bufferBusca.isEmpty ||
            disco.title.localizedCaseInsensitiveContains(bufferBusca)
        }
        .sorted(by: {
            if let pos0 = $0.posicaoCaixa,
               let pos1 = $1.posicaoCaixa {
                pos0 < pos1
            } else {
                true
            }
        })
        .filter({!$0.removed})
    }
    
    @State var adicionandoDisco: Bool = false
    
    var body: some View {
        List {
            ForEach(discosBuscados) { disco in
                NavigationLink {
                    DiscoView(disco: disco)
                } label: {
                    ColecaoPesquisaRow(disco: disco, inCaixa: true)
                }
            }
            .onDelete(perform: deleteItems)
            
        }
        .navigationTitle($caixa.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    adicionandoDisco.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $adicionandoDisco) {
            AddDiscoView(caixa: caixa, adicionandoDisco: $adicionandoDisco)
        }
        .searchable(text: $bufferBusca, prompt: "Pesquisar Discos da Caixa")
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let deletado = discosBuscados[index]
                for disco in caixa.discos {
                    if let pos0 = disco.posicaoCaixa,
                       let pos1 = deletado.posicaoCaixa,
                       pos0 > pos1 {
                        disco.posicaoCaixa! -= 1
                    }
                }
                deletado.posicaoCaixa = nil
                deletado.caixa = nil
            }
        }
    }
}

//#Preview {
//    CaixaView()
//}
