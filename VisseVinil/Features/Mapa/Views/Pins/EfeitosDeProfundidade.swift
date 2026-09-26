//
//  EfeitosDeProfundidade.swift
//  VisseVinil
//

import SwiftUI

// Luz e sombra compartilhadas por pins, selos, bolhas e ícones
enum Profundidade {
    // Degradê dentro da própria cor: puxa pro creme em cima e pro preto embaixo.
    // claro: sem tons escuros; só um brilho creme no topo e a própria cor do meio pra baixo,
    // que é onde fica o símbolo (assim o contraste do símbolo é o da cor base)
    static func miolo(_ cor: Color, claro: Bool = false) -> LinearGradient {
        if claro {
            return LinearGradient(
                stops: [
                    .init(color: cor.mix(with: .creme, by: 0.35), location: 0),
                    .init(color: cor, location: 0.45),
                    .init(color: cor, location: 1),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        return LinearGradient(
            colors: [cor.mix(with: .creme, by: 0.22), cor, escurecida(cor)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static func escurecida(_ cor: Color, claro: Bool = false) -> Color {
        claro ? cor : cor.mix(with: .preto, by: 0.25)
    }

    // Brilho creme na borda, mais forte em cima
    static let brilhoDaBorda = LinearGradient(
        colors: [Color.creme.opacity(0.9), Color.creme.opacity(0.25), Color.creme.opacity(0.05)],
        startPoint: .top,
        endPoint: .bottom
    )
}

// Símbolo "gravado" no pin. No pin claro a sombra é marrom (em vez de preta), o que mantém
// o símbolo creme legível sobre o amarelo sem escurecer o pin.
struct SombraDoSimbolo: ViewModifier {
    let claro: Bool

    func body(content: Content) -> some View {
        content.shadow(color: claro ? Color.marrom.opacity(0.55) : Color.preto.opacity(0.3),
                       radius: claro ? 1.2 : 0.8, y: 0.8)
    }
}

/*
 Três sombras quentes em camadas, cada uma mais larga e mais fraca que a anterior. Juntas
 imitam uma sombra real (escura perto do objeto, se espalhando e sumindo no mapa), o que
 separa o pin do fundo sem precisar de borda grossa.
  - contato: bem curta, "cola" o pin no mapa
  - média: dá o volume
  - ambiente: larga e difusa, mistura o pin com o mapa (cresce quando selecionado)
*/
struct SombrasDeProfundidade: ViewModifier {
    let elevado: Bool
    var intensidade: Double = 1

    func body(content: Content) -> some View {
        content
            .shadow(color: Color.preto.opacity(0.16 * intensidade), radius: 1, y: 0.5)
            .shadow(color: Color.sombra.opacity(0.22 * intensidade),
                    radius: elevado ? 6 : 3.5, y: elevado ? 4 : 2.5)
            .shadow(color: Color.sombra.opacity((elevado ? 0.26 : 0.18) * intensidade),
                    radius: elevado ? 24 : 12, y: elevado ? 16 : 7)
    }
}
