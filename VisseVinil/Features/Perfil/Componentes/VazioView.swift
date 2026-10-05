//
//  EmptyView.swift
//  VisseVinil
//
//  Created by Maria Eduarda Marrocos Honda on 30/09/26.
//

import SwiftUI

enum Componente {
    case meusDiscos
    case discosCurtidos
    case favoritos

    var icone: String {
        switch self {
            case .meusDiscos: "music.note.square.stack"
            case .discosCurtidos: "heart"
            case .favoritos: "star"
        }
    }

    var titulo: String {
        switch self {
            case .meusDiscos: "Sua coleção está vazia"
            case .discosCurtidos: "Você ainda não curtiu discos"
            case .favoritos: "Você ainda não tem discos favoritos"
        }
    }

    var textinho: String {
        switch self {
            case .meusDiscos: "Acesse a página ”Buscar” e\nadicione novos discos"
            case .discosCurtidos: "Acesse a página ”Buscar” e \ncurta os discos que você gosta"
            case .favoritos: "Escolha até 4 discos favoritos\nna edição do seu perfil"
        }
    }
}

struct VazioView: View {

    let coisinha: Componente

    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .frame(width: 50, height: 50)
                    .foregroundStyle(.creme)

                Image(systemName: coisinha.icone)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 22, height: 22)
                    .foregroundStyle(.marrom)

            }
            Text(coisinha.titulo)
                .bold()
                .padding(.bottom, 2)
            Text(coisinha.textinho)
                .font(.body)
                .frame(alignment: .center)
                .multilineTextAlignment(.center)
        }
    }
}
