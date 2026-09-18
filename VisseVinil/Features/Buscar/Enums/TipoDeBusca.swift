//
//  TipoDeBusca.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 16/09/26.
//

import Foundation

enum TipoDeBusca: String, CaseIterable, Codable, Identifiable {
    case disco = "Disco"
    case artista = "Artista"

    var id: String { rawValue }
}
