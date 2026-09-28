//
//  BolhaDeAgrupamento.swift
//  VisseVinil
//

import SwiftUI

/// Bolha de agrupamento: creme (a cor mais próxima do mapa) com número marrom, pra
/// chamar atenção sem "pular" da tela. No modo escuro vira marrom claro com número creme.
/// Mesmo vidro e sombras dos pins.
struct BolhaDeAgrupamento: View {
    let quantidade: Int

    // Miolo + anel fino de vidro = 78 pt. Como o creme é quase a cor do mapa, quem separa a
    // bolha do fundo são as sombras (e não uma borda grossa)
    private let tamanho: CGFloat = 74
    private let anel: CGFloat = 2

    var body: some View {
        Text("+\(quantidade)")
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .foregroundStyle(Color.textoDoAgrupamento)
            .frame(width: tamanho, height: tamanho)
            .background(Circle().fill(Profundidade.miolo(.fundoDoAgrupamento)))
            .overlay {
                // Aro interno quase imperceptível, só pra definir o contorno
                Circle()
                    .stroke(Color.textoDoAgrupamento.opacity(0.12), lineWidth: 0.75)
                    .padding(0.375)
            }
            .padding(anel)
            .glassEffect(.regular.tint(Color.creme.opacity(0.3)).interactive(), in: .circle)
            .modifier(SombrasDeProfundidade(elevado: false, intensidade: 1.25))
            .accessibilityElement()
            .accessibilityLabel("\(quantidade) lugares agrupados")
            .accessibilityHint("Toque para aproximar")
            .accessibilityAddTraits(.isButton)
    }
}
