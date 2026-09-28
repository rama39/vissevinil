//
//  AvaliacaoDoLocal.swift
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
