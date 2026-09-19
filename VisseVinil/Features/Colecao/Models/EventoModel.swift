//
//  Data.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import Foundation
import SwiftData

enum TipoEvento: String, Codable {
    case adicionou
    case tirouParaOuvir
    case comentou
}

@Model
final class EventoModel {
    var data: Date = Date()
    var tipo: TipoEvento
    var comentario: String?
    
    var disco: _DiscoModel?
    
    init(_ tipo: TipoEvento, _ comentario: String = "") {
        self.tipo = tipo
        self.comentario = comentario == "" ?
            nil : comentario
    }
}
