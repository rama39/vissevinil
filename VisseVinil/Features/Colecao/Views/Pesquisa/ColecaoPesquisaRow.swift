//
//  ColecaoPesquisaRow.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 14/09/26.
//

import SwiftUI

struct ColecaoPesquisaRow: View {
    
    var disco: DiscoModel
    
    var inCaixa: Bool
    
    init(disco: DiscoModel, inCaixa: Bool = false) {
        self.disco = disco
        self.inCaixa = inCaixa
    }
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 12) {
            // Carrega a imagem da capa de forma assíncrona
            frameThumb(disco.thumbData)
            
            VStack(alignment: .leading, spacing: 0) {
                let mostraCaixa = !inCaixa && nil != disco.caixa && !disco.removed
                Text(disco.title)
                    .font(.headline)
                    .lineLimit(mostraCaixa ? 1 : 2)
                
                Text("\(disco.released), \(disco.country)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                Spacer()
                
                if mostraCaixa, let caixa = disco.caixa {
                    HStack(spacing: 0) {
                        caixa.cor.frame(width: 5)
                        Text(caixa.title).padding(.horizontal, 5)
                            .font(.subheadline)
                            .lineLimit(1)
                            .frame(height: 20)
                            .background(caixa.cor.opacity(0.3))
                    }
                    .frame(height: 20)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
        }
        .padding(.vertical, 4)
    }
}
