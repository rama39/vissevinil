//
//  Disco.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import Foundation
import SwiftData

@Model
final class DiscoModel {
    var nome: String = "Disco"
    var posicao: Int
    
    @Relationship(deleteRule: .cascade, inverse: \EventoModel.disco)
    var eventos: [EventoModel] = []
    
    init(posicao: Int) {
        self.posicao = posicao
    }
}
