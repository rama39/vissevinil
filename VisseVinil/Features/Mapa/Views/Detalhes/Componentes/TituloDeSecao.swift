//
//  TituloDeSecao.swift
//  VisseVinil
//

import SwiftUI

/// Título de seção da sheet (Title 3 em negrito, como nos cartões do Mapas).
struct TituloDeSecao: View {
    let texto: String

    init(_ texto: String) {
        self.texto = texto
    }

    var body: some View {
        Text(texto)
            .font(.title3.bold())
            .accessibilityAddTraits(.isHeader)
    }
}
