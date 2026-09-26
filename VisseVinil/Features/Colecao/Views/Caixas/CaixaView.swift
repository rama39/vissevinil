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
            $0.posicao > $1.posicao
        })
        .filter({!$0.removed})
    }
    
    @State var adicionandoDisco: Bool = false
    
    var body: some View {
        List(discosBuscados) { disco in
            NavigationLink {
                DiscoView(disco: disco)
            } label: {
                ColecaoPesquisaRow(disco: disco)
            }
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
}

//#Preview {
//    CaixaView()
//}
