//
//  TempPerfil.swift
//  VisseVinil
//
//  Created by Maria Eduarda Marrocos Honda on 21/09/26.
//

import Foundation

struct TempPerfil {

    // MARK: - Dados básicos do usuário

    var name: String
    var photoImageName: String
    /// Data em que o usuário começou a colecionar discos (usada para calcular
    /// "coleciona há X anos e Y meses" dinamicamente, em vez de guardar o
    /// texto pronto).
    var collectingSince: Date

    // MARK: - Discos

    /// Os até 4 discos favoritos, escolhidos pelo usuário no onboarding.
    var favoriteRecords: [DiscoModel]
    /// Discos que o usuário já possui na coleção.
    var myRecords: [DiscoModel]
    /// Discos que o usuário deseja adquirir.
    var wishlistRecords: [DiscoModel]

    //========================================================
    
    init(name: String = "",
         photoImageName: String = "",
         collectingSince: Date = Date(),
         favoriteRecords: [DiscoModel] = [],
         myRecords: [DiscoModel] = [],
         wishlistRecords: [DiscoModel] = []) {
        
        
        
        self.name = name
        self.photoImageName = photoImageName
        self.collectingSince = collectingSince
        self.favoriteRecords = favoriteRecords
        self.myRecords = myRecords
        self.wishlistRecords = wishlistRecords
        
        
        
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

