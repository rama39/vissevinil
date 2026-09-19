//
//  Disco.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import Foundation
import SwiftData

@Model
final class _DiscoModel {
    var title: String
    var artists: [String]
    var year: String
    var country: String
    var genres: [String]
    // não temos acesso a avaliação global nem cor do disco
    var styles: [String]
    var id: Int
    
    // posicao na coleção
    var posicao: Int
    
    @Relationship(deleteRule: .cascade, inverse: \EventoModel.disco)
    var eventos: [EventoModel] = []
    
    var caixa: CaixaModel?
    
    @Attribute(.externalStorage)
    var thumb: Data? = nil
    
    init(
        title: String, artists: [String], year: String, country: String, genres: [String], styles: [String],
        id: Int,
        posicao: Int
    ) {
        self.title = title
        self.artists = artists
        self.year = year
        self.country = country
        self.genres = genres
        self.styles = styles
        self.id = id
        self.posicao = posicao
    }
}
