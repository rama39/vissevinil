//
//  LocalSalvo.swift
//  VisseVinil
//

import Foundation

/// Local guardado no UserDefaults (usado pelos recentes, favoritos e fixados).
struct LocalSalvo: Codable, Identifiable {
    let id: UUID
    let nome: String
    let latitude: Double
    let longitude: Double
    let endereco: String?
    // Nome da loja cadastrada (nil = local avulso). Loja cadastrada é identificada pelo
    // nome, e não pela coordenada, porque a coordenada pode ser atualizada pela internet.
    var lojaID: String? = nil
}
