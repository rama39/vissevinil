//
//  CartaoDeAvaliacao.swift
//  VisseVinil
//

import SwiftUI

/// Uma avaliação: estrelas, dia/hora e comentário.
struct CartaoDeAvaliacao: View {
    let avaliacao: AvaliacaoDoLocal
    var comFundo = true

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                if avaliacao.nota > 0 {
                    EstrelasDeNota(nota: Double(avaliacao.nota))
                }
                Spacer()
                Text(avaliacao.data.formatted(.dateTime.day().month(.abbreviated).year().hour().minute()))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if let comentario = avaliacao.comentario, !comentario.isEmpty {
                Text(comentario)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(comFundo ? 16 : 0)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            if comFundo {
                RoundedRectangle(cornerRadius: 14, style: .continuous).fill(Color(.secondarySystemFill))
            }
        }
        .accessibilityElement(children: .combine)
    }
}
