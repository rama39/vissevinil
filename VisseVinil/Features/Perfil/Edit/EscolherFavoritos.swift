//
//  EscolherFavoritos.swift
//  VisseVinil
//
//  Created by Maria Eduarda Marrocos Honda on 22/09/26.
//

import SwiftUI

struct EscolherFavoritos: View {
    @Binding var adicionarFavorito: Bool // recebe valor de referencia
    
    var body: some View {
        Button{
            adicionarFavorito = true
        } label: {
            HStack{
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(.tint)
                Text("Adicionar 4 discos preferidos")
                Spacer()
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    List {
        Section {
            EscolherFavoritos(adicionarFavorito: .constant(true))
        }
    }
}
