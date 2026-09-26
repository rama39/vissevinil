//
//  LojaDetailView.swift
//  VisseVinil
//
//  Created by Gabriel Alves Gadelha de Melo on 24/09/26.
//

import SwiftUI

struct LojaDetailView: View {
    let loja: Loja
    let ehFavorito: Bool
    let onToggleFavorito: () -> Void

    var body: some View {
       

         
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(loja.officialName ?? loja.nameForSearch)
                    .font(.title2.bold())
                
                Spacer()
                
                Button(action: onToggleFavorito) {
                    Image(systemName: ehFavorito ? "star.fill" : "star")
                }
            }
            
            if let category = loja.category {
                Text(category)
                    .foregroundStyle(.secondary)
            }
            
            if let address = loja.address {
                Label(address, systemImage: "mappin.and.ellipse")
            }
            
            if let fone = loja.fone {
                Label(fone, systemImage: "phone")
            }
            
            if let website = loja.website {
                Label(website, systemImage: "globe")
            }
            
            if let ig = loja.ig {
                Label(ig, systemImage: "camera")
            }
        }
        .padding()
    }
}
