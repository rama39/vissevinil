//
//  AddToCaixaView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 08/10/26.
//

import SwiftUI
import SwiftData

struct AddToCaixaView: View {
    
    @Query private var caixas: [CaixaModel]
    
    @Bindable var disco: DiscoModel
    
    var body: some View {
        NavigationStack {
            List(caixas) { caixa in
                HStack {
                    BotaoSaveCaixa(disco: disco, caixa: caixa)
                    CaixaOuterView(caixa: caixa, count: 4)
                }
                .listRowSeparator(.hidden)
            }
            .navigationTitle("Adicionar disco a uma caixa")
            .navigationBarTitleDisplayMode(.inline)
            .listStyle(.plain)
            .listRowSpacing(0)
        }
    }
}
