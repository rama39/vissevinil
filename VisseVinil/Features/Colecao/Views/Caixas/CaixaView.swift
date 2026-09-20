//
//  CaixaView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import SwiftUI

struct CaixaView: View {
    
    @Bindable var caixa: CaixaModel
    
    @State var adicionandoDisco: Bool = false
    
    var body: some View {
        List(caixa.discos) { disco in
            NavigationLink {
                DiscoView(disco: disco)
            } label: {
                ColecaoPesquisaRow(disco: disco)
            }
        }
        .navigationTitle($caixa.title)
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
    }
}

//#Preview {
//    CaixaView()
//}
