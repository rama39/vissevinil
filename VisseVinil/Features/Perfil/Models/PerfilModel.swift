//
//  PerfilModel.swift
//  VisseVinil
//
//  Created by Pedro Augusto Santos de Sousa on 16/09/26.
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class PerfilModel {

    // MARK: - Dados básicos do usuário
    @Attribute(.externalStorage) var imagePhotoName: Data?
    //foto opcional p n ser obgriado a colocar
    
    var name: String
    /// Data em que o usuário começou a colecionar discos (usada para calcular
    /// "coleciona há X anos e Y meses" dinamicamente, em vez de guardar o
    /// texto pronto).
    var collectingSince: Date

    /// Cor/degradê da borda da foto (sugestão ou "#RRGGBB", ver BordaDoPerfil); nil = padrão.
    /// Opcional pra perfis já salvos migrarem sem perder dados.
    var bordaDaFoto: String?

    //========================================================

    init(imagePhotoName: Data? = nil, name: String = "",
         collectingSince: Date = Date()) {
        
        // variavel tipo data opcional que se n receber nada é nil
        self.imagePhotoName = imagePhotoName
        self.name = name
        self.collectingSince = collectingSince
    }

    // MARK: - Texto derivado

    /// Ex.: "coleciona discos há 2 anos e 6 meses".
    var collectingTimeDescription: String {
        let components = Calendar.current.dateComponents([.year, .month], from: collectingSince, to: Date())
        let years = max(components.year ?? 0, 0)
        let months = max(components.month ?? 0, 0)

        var parts: [String] = []
        if years > 0 {
            parts.append("\(years) ano\(years == 1 ? "" : "s")")
        }
        if months > 0 {
            parts.append("\(months) mes\(months == 1 ? "" : "es")")
        }
        if parts.isEmpty {
            return "coleciona discos há menos de um mês"
        }
        return "coleciona discos há " + parts.joined(separator: " e ")
    }
}
