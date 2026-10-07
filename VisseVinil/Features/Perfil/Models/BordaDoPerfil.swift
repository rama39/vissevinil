//
//  BordaDoPerfil.swift
//  VisseVinil
//

import SwiftUI
import UIKit

/// Cor (ou degradê) da borda da foto de perfil, escolhida na edição do perfil.
/// Salva no PerfilModel (`bordaDaFoto`) como texto: o nome de uma sugestão ("vinho") ou uma
/// cor escolhida pela pessoa em hexadecimal ("#3A7BD5"). nil = marrom padrão.
enum BordaDoPerfil {

    /// Cores e degradês sugeridos (da paleta do app)
    enum Sugestao: String, CaseIterable, Identifiable {
        case marrom
        case vinho
        case mostarda
        case tocaDiscos
        case porDoSol
        case holografico

        static let padrao = Sugestao.marrom

        var id: String { rawValue }

        var nome: String {
            switch self {
            case .marrom: "Marrom"
            case .vinho: "Vinho"
            case .mostarda: "Mostarda"
            case .tocaDiscos: "Degradê Toca-Discos"
            case .porDoSol: "Degradê Pôr do Sol"
            case .holografico: "Degradê Holográfico"
            }
        }

        var estilo: AnyShapeStyle {
            switch self {
            case .marrom: AnyShapeStyle(Color.bordaDoPerfil)
            case .vinho: AnyShapeStyle(Color.vinho)
            case .mostarda: AnyShapeStyle(Color.mostarda)
            case .tocaDiscos: Self.degrade([.bordaDoPerfil, .vinho])
            case .porDoSol: Self.degrade([.mostarda, .vinho])
            // Perolado, como o brilho de um disco na luz
            case .holografico: Self.degrade([Color(red: 0.96, green: 0.66, blue: 0.80),
                                             Color(red: 0.72, green: 0.64, blue: 0.95),
                                             Color(red: 0.55, green: 0.80, blue: 0.96),
                                             Color(red: 0.62, green: 0.92, blue: 0.80),
                                             Color(red: 0.98, green: 0.88, blue: 0.62)])
            }
        }

        /// Cor de partida do seletor de cor quando esta sugestão está escolhida
        var corBase: Color {
            switch self {
            case .marrom, .tocaDiscos: .bordaDoPerfil
            case .vinho: .vinho
            case .mostarda, .porDoSol: .mostarda
            case .holografico: .purple
            }
        }

        // Degradê angular fechado (a última cor volta pra primeira, sem emenda)
        private static func degrade(_ cores: [Color]) -> AnyShapeStyle {
            AnyShapeStyle(AngularGradient(colors: cores + [cores[0]], center: .center,
                                          startAngle: .degrees(-90), endAngle: .degrees(270)))
        }
    }

    /// Estilo pra pintar a borda a partir do valor salvo
    static func estilo(_ valor: String?) -> AnyShapeStyle {
        if let sugestao = sugestao(valor) {
            return sugestao.estilo
        }
        if let cor = corPersonalizada(valor) {
            return AnyShapeStyle(cor)
        }
        return Sugestao.padrao.estilo
    }

    /// Sugestão salva (nil quando é uma cor personalizada); sem nada salvo, o padrão
    static func sugestao(_ valor: String?) -> Sugestao? {
        guard let valor else { return .padrao }
        return Sugestao(rawValue: valor)
    }

    /// Cor escolhida no seletor, salva como "#RRGGBB"
    static func corPersonalizada(_ valor: String?) -> Color? {
        guard let valor, valor.hasPrefix("#"),
              let numero = UInt32(valor.dropFirst(), radix: 16) else { return nil }
        return Color(red: Double((numero >> 16) & 0xFF) / 255,
                     green: Double((numero >> 8) & 0xFF) / 255,
                     blue: Double(numero & 0xFF) / 255)
    }

    static func valor(de cor: Color) -> String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        UIColor(cor).getRed(&r, green: &g, blue: &b, alpha: &a)
        let canal = { (v: CGFloat) in Int((min(max(v, 0), 1) * 255).rounded()) }
        return String(format: "#%02X%02X%02X", canal(r), canal(g), canal(b))
    }
}
