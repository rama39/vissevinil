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

    var name: String
    var photoImageName: String
    /// Data em que o usuário começou a colecionar discos (usada para calcular
    /// "coleciona há X anos e Y meses" dinamicamente, em vez de guardar o
    /// texto pronto).
    var collectingSince: Date

    //========================================================

    init(name: String = "",
         photoImageName: String = "",
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
