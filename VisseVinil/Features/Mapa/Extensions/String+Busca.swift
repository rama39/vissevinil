//
//  String+Busca.swift
//  VisseVinil
//

import Foundation

extension String {
    // "Taberna do Vinil" == "TABERNA DO VINIL" == "Tabérna do vinil": sem acento, caixa ou pontuação
    var normalizadoParaBusca: String {
        folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .filter { $0.isLetter || $0.isNumber }
    }

    // Um nome contém o outro (ex: "Pulga" x "Pulga Mercado de Discos")
    func pareceONomeDe(_ outro: String) -> Bool {
        let a = normalizadoParaBusca
        let b = outro.normalizadoParaBusca
        return !a.isEmpty && !b.isEmpty && (a.contains(b) || b.contains(a))
    }

    // "  texto  " -> "texto"; "   " -> nil
    var nilSeVazio: String? {
        let limpo = trimmingCharacters(in: .whitespacesAndNewlines)
        return limpo.isEmpty ? nil : limpo
    }
}
