//
//  SaveCaixaButton.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 08/10/26.
//

import SwiftUI
import SwiftData

struct BotaoSaveCaixa: View {
    @Environment(\.modelContext) private var modelContext
    func save() { if modelContext.hasChanges { try? modelContext.save() } }
    @Query private var caixas: [CaixaModel]
    
    @Bindable var disco: DiscoModel
    let caixa: CaixaModel
    
    var body: some View {
        let saved = disco.caixa == caixa
        Button {
            withAnimation {
                disco.caixa = saved ? nil : caixa
                // TODO gerenciar posicionamento na caixa
                // sinceramente gosto que a mudança seja lowkey e com poucas consequências
                // é um botaozinho man. vai q eu tiro sem querer e vai pro final da caixa
                // ok tem q lidar com o caso do removed
                // difícil. Designer!!
            }
        } label: {
            let systemName = saved ?
            "checkmark" : "plus"
            Image(systemName: systemName)
                .frame(width:25, height: 25)
                .background{
                    let cor = saved ? Color.green : Color.blue
                    cor.opacity(0.5)
                }
                .clipShape(RoundedRectangle(cornerRadius: 100))
        }
    }
}
