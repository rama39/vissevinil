//
//  Data.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import Foundation
import SwiftData

enum TipoEvento: String, Codable {
    case adicionou = "Adicionou disco na coleção"
    case tirouParaOuvir = "Tirou disco para ouvir"
    case comentou = "Criou comentário"
}

let imageEvento: [TipoEvento: String] = [
    .adicionou: "opticaldisc",
    .tirouParaOuvir: "tray.and.arrow.up",
    .comentou: "bubble"
]

@Model
final class EventoModel {
    var data: Date = Date()
    var tipo: TipoEvento
    var comentario: String?
    
    var disco: DiscoModel?
    
    init(_ tipo: TipoEvento, _ comentario: String = "") {
        self.tipo = tipo
        self.comentario = comentario == "" ?
            nil : comentario
    }
}
