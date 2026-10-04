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
            ZStack {
                if let thumbUrlString = release.thumb, let thumbUrl = URL(string: thumbUrlString) {
                    AsyncImage(url: thumbUrl) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    //.frame(width: 70, height: 70)
                    .cornerRadius(8)
                    .clipped()
                } else { noThumb }
                VStack {
                    Spacer()
                    HStack {
                        CurtidaSearch(id: release.id)
                        Spacer()
                    }
                }
            }
            .frame(width: 70, height: 70)
            
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
