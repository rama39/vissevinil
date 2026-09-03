//
//  Disco.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import Foundation
import SwiftData

@Model
final class Disco {
    var nome: String = ""
    var posicao: Int
    
    @Relationship(deleteRule: .cascade, inverse: \Evento.disco)
    var eventos: [Evento] = []
    
    init(posicao: Int) {
        self.posicao = posicao
    }
}
