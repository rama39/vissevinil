//
//  LinhaDeLocal.swift
//  VisseVinil
//

import SwiftUI

/// Linha de lista com o ícone do tipo de lugar, título e subtítulo (recentes e sugestões).
struct LinhaDeLocal: View {
    let titulo: Text
    let subtitulo: String?
    let estilo: EstiloDeLocal
    let acao: () -> Void

    var body: some View {
        Button(action: acao) {
            HStack(spacing: 12) {
                IconeDeLocal(estilo: estilo)

                VStack(alignment: .leading, spacing: 2) {
                    titulo
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    if let subtitulo, !subtitulo.isEmpty {
                        Text(subtitulo)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
        .foregroundStyle(.primary)
    }
}
