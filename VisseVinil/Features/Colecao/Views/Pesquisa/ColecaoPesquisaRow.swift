//
//  ColecaoPesquisaRow.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 14/09/26.
//

import SwiftUI

struct ColecaoPesquisaRow: View {
    
    var disco: DiscoModel
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 12) {
            // Carrega a imagem da capa de forma assíncrona
            frameThumb(disco.thumbData, frame: 60, radius: 4)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(disco.title)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack {
                    Text("\(disco.released), \(disco.country)")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
