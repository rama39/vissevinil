//
//  PreferenciasDoMapa.swift
//  VisseVinil
//

import Foundation

/// Como os locais aparecem no mapa. Salvo no aparelho (@AppStorage).
enum ExibicaoDosLocais: String, CaseIterable, Identifiable {
    /// Locais próximos viram uma bolha com a quantidade
    case agrupados
    /// Todos os locais com o ícone completo, sem agrupar
    case icones
    /// Todos os locais como um ponto na cor da classe principal (Loja > Favorito > Fixado)
    case pontos

    var id: String { rawValue }

    var titulo: String {
        switch self {
        case .agrupados: "Agrupados"
        case .icones: "Ícones"
        case .pontos: "Pontos"
        }
    }

    var icone: String {
        switch self {
        case .agrupados: "circle.hexagongrid.fill"
        case .icones: "mappin.and.ellipse"
        case .pontos: "circle.fill"
        }
    }

    /// Próximo modo ao tocar no botão (Agrupados → Ícones → Pontos → Agrupados)
    var proximo: ExibicaoDosLocais {
        let todos = Self.allCases
        let indice = todos.firstIndex(of: self) ?? 0
        return todos[(indice + 1) % todos.count]
    }

    var agrupa: Bool { self == .agrupados }
    var usaPontos: Bool { self == .pontos }
}
