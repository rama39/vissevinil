//
//  ReleaseRow.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 11/09/26.
//

import SwiftUI

struct SearchRow: View {
    
    @State var release: DiscogsRelease
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 12) {
            // Carrega a imagem da capa de forma assíncrona
            if let thumbUrlString = release.thumb, let thumbUrl = URL(string: thumbUrlString) {
                AsyncImage(url: thumbUrl) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color.gray.opacity(0.3)
                }
                .frame(width: 60, height: 60)
                .cornerRadius(4)
                .clipped()
            } else { placeholder }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(release.title ?? "Disco")
                    .font(.headline)
                    .lineLimit(2)
                
                Text(release.yearCountry)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
