//
//  TipoTagView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 16/09/26.
//

import SwiftUI

struct TipoTagView: View {
    let tipo: TipoDeBusca
    @Binding var tipoSelecionado: TipoDeBusca
    var selecionado: Bool { tipoSelecionado == tipo }

    var body: some View {
        Button(action: { withAnimation {
            tipoSelecionado = tipo
        }}) {
            ZStack {
                Capsule()
                    .foregroundStyle(
                        selecionado ?
                            Color.accentColor :
                            Color(.secondarySystemBackground)
                    )
                Text(tipo.rawValue)
                    .font(.subheadline)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .foregroundStyle(selecionado ? .white : .primary)
            }
        }
        .buttonStyle(.plain)
    }
}
