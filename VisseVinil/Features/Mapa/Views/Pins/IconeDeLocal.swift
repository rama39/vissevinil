//
//  IconeDeLocal.swift
//  VisseVinil
//

import SwiftUI

/// Ícone das listas (busca, fixados, favoritos, recentes), com a mesma forma e cor do pin no
/// mapa, pra pessoa reconhecer o tipo de lugar nos dois lugares.
struct IconeDeLocal: View {
    let cor: Color
    let icone: String
    var corDoIcone: Color = .creme
    var formato: PinDoMapa.Formato = .circulo
    var claro = false
    var tamanho: CGFloat = 30

    var body: some View {
        Image(systemName: icone)
            .font(.system(size: tamanho * 0.46, weight: .semibold))
            .foregroundStyle(corDoIcone)
            .modifier(SombraDoSimbolo(claro: claro))
            .frame(width: tamanho, height: tamanho)
            .background(forma.fill(Profundidade.miolo(cor, claro: claro)))
            .overlay(forma.stroke(Profundidade.brilhoDaBorda, lineWidth: 1).padding(0.5))
            .accessibilityHidden(true)
    }

    private var forma: AnyShape {
        switch formato {
        case .circulo:
            AnyShape(Circle())
        case .retangulo:
            AnyShape(RoundedRectangle(cornerRadius: tamanho * 0.27, style: .continuous))
        }
    }
}
