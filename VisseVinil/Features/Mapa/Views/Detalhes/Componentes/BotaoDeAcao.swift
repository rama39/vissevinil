//
//  BotaoDeAcao.swift
//  VisseVinil
//

import SwiftUI

/// Botão grande de ação (como os do Mapas). Cinza e desativado quando não há o dado.
struct BotaoDeAcao: View {
    let titulo: String
    let icone: String
    var destaque = false
    let habilitado: Bool
    let acao: () -> Void

    var body: some View {
        Button(action: acao) {
            VStack(spacing: 4) {
                Image(systemName: icone)
                    .font(.title3)
                Text(titulo)
                    .font(.footnote.weight(.semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, minHeight: 58)
            .foregroundStyle(corDoConteudo)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(corDoFundo))
        }
        .buttonStyle(.plain)
        .disabled(!habilitado)
        .accessibilityLabel(titulo)
    }

    private var corDoConteudo: Color {
        guard habilitado else { return .secondary }
        return destaque ? .creme : .accentColor
    }

    private var corDoFundo: Color {
        habilitado && destaque ? .vinho : Color(.tertiarySystemFill)
    }
}
