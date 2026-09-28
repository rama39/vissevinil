//
//  CarrosselDeLocais.swift
//  VisseVinil
//

import SwiftUI

/// Fixados/favoritos: ícones grandes em rolagem lateral. Pra remover, toque longo (menu de
/// contexto), já que deslizar pro lado conflita com a rolagem horizontal.
struct CarrosselDeLocais: View {
    let locais: [Loja]
    let estilo: (Loja) -> EstiloDeLocal
    let textoRemover: String
    let iconeRemover: String
    let remover: (Loja) -> Void
    let selecionar: (Loja) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(locais) { loja in
                    Button {
                        selecionar(loja)
                    } label: {
                        VStack(spacing: 6) {
                            IconeDeLocal(estilo: estilo(loja), tamanho: 56)
                            Text(loja.officialName ?? loja.nameForSearch)
                                .font(.caption)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .frame(width: 72)
                        }
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(textoRemover, systemImage: iconeRemover) {
                            remover(loja)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}
