//
//  GeneroTagView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 15/09/26.
//

import SwiftUI

struct GeneroTagView: View {
    let genero: DiscogsGenre
    @Binding var tagSelecionada: DiscogsGenre?
    var selecionado: Bool { tagSelecionada == genero }

    var body: some View {
        Button(action: {
            tagSelecionada = selecionado ? nil : genero
        }) {
            Text(genero.rawValue)
                .font(.subheadline)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(selecionado ? Color.accentColor : Color(.secondarySystemBackground))
                .foregroundStyle(selecionado ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
