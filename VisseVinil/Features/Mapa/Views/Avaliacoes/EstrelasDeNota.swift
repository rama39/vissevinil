//
//  EstrelasDeNota.swift
//  VisseVinil
//

import SwiftUI

/// Estrelas só pra exibir uma nota (aceita meia estrela, ex: média 4,5).
struct EstrelasDeNota: View {
    let nota: Double

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { posicao in
                Image(systemName: simbolo(para: posicao))
            }
        }
        .font(.caption)
        .foregroundStyle(Color.mostarda)
        .accessibilityElement()
        .accessibilityLabel("\(nota.formatted(.number.precision(.fractionLength(0...1)))) de 5 estrelas")
    }

    private func simbolo(para posicao: Int) -> String {
        let valor = nota - Double(posicao - 1)
        if valor >= 0.75 { return "star.fill" }
        if valor >= 0.25 { return "star.leadinghalf.filled" }
        return "star"
    }
}
