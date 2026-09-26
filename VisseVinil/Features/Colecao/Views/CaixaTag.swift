//
//  CaixaTag.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 26/09/26.
//

import SwiftUI

struct CaixaTag: View {
    
    let caixa: CaixaModel
    
    var body: some View {
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
