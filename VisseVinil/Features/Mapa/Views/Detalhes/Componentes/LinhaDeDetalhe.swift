//
//  LinhaDeDetalhe.swift
//  VisseVinil
//

import SwiftUI

/// Linha de "Detalhes": nome do campo à esquerda (com um acessório opcional ao lado, ex: o
/// botão de copiar) e a informação à direita.
struct LinhaDeDetalhe<Valor: View, Acessorio: View>: View {
    let campo: String
    @ViewBuilder let valor: Valor
    @ViewBuilder let acessorio: Acessorio

    init(campo: String, @ViewBuilder valor: () -> Valor,
         @ViewBuilder acessorio: () -> Acessorio = { EmptyView() }) {
        self.campo = campo
        self.valor = valor()
        self.acessorio = acessorio()
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            HStack(spacing: 8) {
                Text(campo)
                    .foregroundStyle(.secondary)
                acessorio
            }

            valor
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .font(.body)
        .padding(.vertical, 12)
    }
}
