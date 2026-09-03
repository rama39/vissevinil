//
//  Data.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import Foundation
import SwiftData

@Model
final class Evento {
    var data: Date = Date()
    var tipo: TipoEvento
    var comentario: String?
    
    var disco: Disco?
    
    init(_ tipo: TipoEvento, _ comentario: String = "") {
        self.tipo = tipo
        self.comentario = comentario == "" ?
            nil : comentario
    }
}
