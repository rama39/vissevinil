//
//  BotaoDeExibicaoDosLocais.swift
//  VisseVinil
//

import SwiftUI

/*
 Botão redondo de vidro, do mesmo tamanho do botão de localização (44 pt, o mínimo de toque
 da HIG), que funciona do mesmo jeito que ele: cada toque alterna o modo e o ícone mostra o
 modo atual (Agrupados → Ícones → Pontos). Como só o ícone pode não deixar claro o que mudou,
 o nome do modo aparece ao lado por um instante.
*/
struct BotaoDeExibicaoDosLocais: View {
    @Binding var exibicao: ExibicaoDosLocais

    @State private var mostrandoNome = false
    @State private var tarefaDoNome: Task<Void, Never>?

    var body: some View {
        Button(action: alternar) {
            Image(systemName: exibicao.icone)
                .font(.body.weight(.medium))
                .contentTransition(.symbolEffect(.replace))
                .frame(width: 44, height: 44)
                .contentShape(Circle())
                .glassEffect(.regular.interactive(), in: .circle)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.accentColor)
        .overlay(alignment: .trailing) {
            if mostrandoNome {
                Text(exibicao.titulo)
                    .font(.footnote.weight(.semibold))
                    .fixedSize()
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .glassEffect(.regular, in: .capsule)
                    // À esquerda do botão
                    .offset(x: -54)
                    .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .trailing)))
                    .allowsHitTesting(false)
            }
        }
        .sensoryFeedback(.selection, trigger: exibicao)
        .accessibilityLabel("Exibição dos locais")
        .accessibilityValue(exibicao.titulo)
        .accessibilityHint("Toque para alternar entre agrupados, ícones e pontos")
    }

    private func alternar() {
        exibicao = exibicao.proximo

        withAnimation(.easeOut(duration: 0.2)) {
            mostrandoNome = true
        }
        tarefaDoNome?.cancel()
        tarefaDoNome = Task {
            try? await Task.sleep(for: .seconds(1.5))
            guard !Task.isCancelled else { return }
            withAnimation(.easeIn(duration: 0.3)) {
                mostrandoNome = false
            }
        }
    }
}
