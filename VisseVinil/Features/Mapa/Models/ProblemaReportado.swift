//
//  ProblemaReportado.swift
//  VisseVinil
//

import Foundation
import SwiftData

/// Problema comunicado pela pessoa sobre um local (endereço errado, fechado etc.).
/// Por enquanto fica salvo no aparelho; ainda não há um servidor pra onde enviar.
@Model
final class ProblemaReportado {
    var chaveDoLocal: String
    var nomeDoLocal: String
    var tipo: String
    var descricao: String
    var data: Date

    init(chaveDoLocal: String, nomeDoLocal: String, tipo: String, descricao: String, data: Date = .now) {
        self.chaveDoLocal = chaveDoLocal
        self.nomeDoLocal = nomeDoLocal
        self.tipo = tipo
        self.descricao = descricao
        self.data = data
    }
}
