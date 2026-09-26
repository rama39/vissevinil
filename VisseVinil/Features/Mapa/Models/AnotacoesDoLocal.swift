//
//  AnotacoesDoLocal.swift
//  VisseVinil
//

import Foundation
import SwiftData

/*
 Avaliação pessoal de um local: só a própria pessoa vê. A "média" mostrada na sheet é a
 média das avaliações DELA (várias visitas ao mesmo lugar), não de outros usuários.
 O local é identificado pela mesma chave de favoritos/fixados: "loja:<nome>" pra lojas
 cadastradas e "lat,lon" pra locais avulsos.
*/
@Model
final class AvaliacaoDoLocal {
    var chaveDoLocal: String
    // 1 a 5 estrelas; 0 = só comentário, sem nota (fica fora da média)
    var nota: Int
    var comentario: String?
    var data: Date

    init(chaveDoLocal: String, nota: Int, comentario: String?, data: Date = .now) {
        self.chaveDoLocal = chaveDoLocal
        self.nota = nota
        self.comentario = comentario
        self.data = data
    }
}

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

/// Telefone/site informados pela própria pessoa quando o Apple Maps não tem (ou tem errado).
/// Fica separado da Loja pra atualização automática (a cada 20 dias) não apagar o que ela
/// digitou, e funciona também pra locais avulsos. O endereço não é editável.
@Model
final class ContatoDoLocal {
    var chaveDoLocal: String
    var telefone: String?
    var site: String?

    init(chaveDoLocal: String, telefone: String?, site: String?) {
        self.chaveDoLocal = chaveDoLocal
        self.telefone = telefone
        self.site = site
    }
}
