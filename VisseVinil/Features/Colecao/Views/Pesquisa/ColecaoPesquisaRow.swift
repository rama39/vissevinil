//
//  ColecaoPesquisaRow.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 14/09/26.
//

import SwiftUI

struct ColecaoPesquisaRow: View {
    
    var disco: _DiscoModel
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 12) {
            // Carrega a imagem da capa de forma assíncrona
            if let thumb = disco.thumb,
               let uiImage = UIImage(data: thumb) {
                Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .cornerRadius(4)
                .clipped()
            } else {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 60, height: 60)
                    .overlay(Image(systemName: "music.note"))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(disco.title)
                    .font(.headline)
                    .lineLimit(2)
                
                HStack {
                    Text("\(disco.year), \(disco.country)")
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
