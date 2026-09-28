//
//  CabecalhoDaBusca.swift
//  VisseVinil
//

import SwiftUI

/// Título de seção da busca (Fixados, Favoritos, Recentes), em destaque como no app Mapas.
/// Color.primary (e não o estilo .primary) pra o fundo desfocado não deixar o texto acinzentado.
struct CabecalhoDaBusca: View {
    let titulo: String

    init(_ titulo: String) {
        self.titulo = titulo
    }

    var body: some View {
        Text(titulo)
            .font(.title3.bold())
            .foregroundStyle(Color.primary)
            .textCase(nil)
    }
}
