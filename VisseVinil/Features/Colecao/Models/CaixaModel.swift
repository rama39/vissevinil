//
//  Data.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import Foundation
import SwiftData

@Model
final class CaixaModel {
    var title: String
    var rgba: RGBAColor

    // Ordenação escolhida pra esta caixa (cada caixa lembra a sua). Opcionais pra caixas
    // criadas antes de existir ordenação; o padrão é a ordem manual.
    var ordenacaoSalva: String? = nil
    var ordemCrescenteSalva: Bool? = nil
    
    @Relationship(deleteRule: .nullify, inverse: \DiscoModel.caixa)
    var discos: [DiscoModel] = []
    
    init(title: String, rgba: RGBAColor) {
        self.title = title
        self.rgba = rgba
    }
}

extension CaixaModel {
    /// Critério de ordenação desta caixa (Manual quando nunca foi escolhido)
    var ordenacao: Ordenacao {
        get { ordenacaoSalva.flatMap(Ordenacao.init(rawValue:)) ?? .manual }
        set { ordenacaoSalva = newValue.rawValue }
    }

    var ordemCrescente: Bool {
        get { ordemCrescenteSalva ?? ordenacao.crescentePorPadrao }
        set { ordemCrescenteSalva = newValue }
    }
}
