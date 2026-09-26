//
//  SeletorDeEstrelas.swift
//  VisseVinil
//

import SwiftUI

/// Toque numa estrela pra dar a nota; tocar de novo na mesma tira a nota.
struct SeletorDeEstrelas: View {
    @Binding var nota: Int

    var body: some View {
        HStack(spacing: 10) {
            ForEach(1...5, id: \.self) { posicao in
                Button {
                    nota = (nota == posicao) ? 0 : posicao
                } label: {
                    Image(systemName: posicao <= nota ? "star.fill" : "star")
                        .font(.title)
                        .foregroundStyle(posicao <= nota ? Color.mostarda : Color.secondary)
                        .symbolEffect(.bounce, value: nota == posicao)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .sensoryFeedback(.selection, trigger: nota)
        .accessibilityElement()
        .accessibilityLabel("Nota")
        .accessibilityValue(nota == 0 ? "Sem nota" : "\(nota) de 5 estrelas")
        .accessibilityAdjustableAction { direcao in
            switch direcao {
            case .increment: nota = min(nota + 1, 5)
            case .decrement: nota = max(nota - 1, 0)
            @unknown default: break
            }
        }
    }
}
