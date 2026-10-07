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
    var photoImageName: Data?
    var collectingSince: Date
    var bordaDaFoto: String?

    //========================================================

    init(name: String = "",
         photoImageName: Data? = nil,
         collectingSince: Date = Date()) {
        self.name = name
        self.photoImageName = photoImageName
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
