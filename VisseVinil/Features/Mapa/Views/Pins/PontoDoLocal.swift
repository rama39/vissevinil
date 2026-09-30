//
//  PontoDoLocal.swift
//  VisseVinil
//

import SwiftUI

/// Modo "Pontos": o local vira só um ponto na cor da classe principal, com a mesma
/// profundidade dos pins. A área de toque tem 44 pt (mínimo da HIG), maior que o ponto.
struct PontoDoLocal: View {
    let cor: Color

    private let diametro: CGFloat = 14

    var body: some View {
        Circle()
            .fill(Profundidade.miolo(cor))
            .frame(width: diametro, height: diametro)
            .overlay(Circle().stroke(Color.creme, lineWidth: 2))
            .modifier(SombrasDeProfundidade(elevado: false))
            .frame(width: 44, height: 44)
            .contentShape(Circle())
    }
}

/// Marcador de um local no mapa: pin completo ou ponto, conforme a exibição escolhida.
/// No modo "Pontos", o local selecionado vira o pin completo (fica claro qual está aberto).
struct MarcadorDoLocal: View {
    let estilo: EstiloDeLocal
    let selecionado: Bool
    let comoPonto: Bool

    var body: some View {
        if comoPonto && !selecionado {
            PontoDoLocal(cor: estilo.cor)
        } else {
            PinDoMapa(estilo: estilo, selecionado: selecionado)
        }
    }
}
