//
//  SearchRow.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 01/10/26.
//



import SwiftUI

struct CurtidaRow: View {
    
    let curtida: CurtidaModel
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 12) {
            // Carrega a imagem da capa de forma assíncrona
            if let thumbUrlString = curtida.images?[0].resourceURL, let thumbUrl = URL(string: thumbUrlString) {
                AsyncImage(url: thumbUrl) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 70, height: 70)
                .cornerRadius(8)
                .clipped()
            } else { noThumb() }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(curtida.master_title ?? "Disco")
                    .font(.headline)
                    .lineLimit(2)
                
                Text(curtida.artistsListed)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
