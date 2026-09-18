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

    // MARK: - Discos

    /// Os até 4 discos favoritos, escolhidos pelo usuário no onboarding.
    var favoriteRecords: [DiscoModel]
    /// Discos que o usuário já possui na coleção.
    var myRecords: [DiscoModel]
    /// Discos que o usuário deseja adquirir.
    var wishlistRecords: [DiscoModel]

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

    // MARK: - Ações

    /// Chamado pelo onboarding (ou pela tela de edição) para atualizar os favoritos.
    /// Mantém no máximo 4 discos, como definido no fluxo de onboarding.
    func updateFavoriteRecords(_ records: [DiscoModel]) {
        favoriteRecords = Array(records.prefix(4))
    }

    func addToMyRecords(_ record: DiscoModel) {
        myRecords.append(record)
    }

    func addToWishlist(_ record: DiscoModel) {
        wishlistRecords.append(record)
    }

    func removeFromWishlist(_ record: DiscoModel) {
        wishlistRecords.removeAll { $0.id == record.id }
    }
}

// MARK: - Perfil de exemplo

extension PerfilModel {
    /// Usado só até existir onboarding de verdade criando o perfil do usuário.
    /// Serve pra visualizar a tela completa (favoritos, coleção, wishlist)
    /// enquanto isso não existe. Pode ser apagado assim que o onboarding
    /// estiver pronto.
    static var exemplo: PerfilModel {
        PerfilModel(
            name: "Matheus",
            photoImageName: "profile_photo",
            collectingSince: Calendar.current.date(byAdding: .month, value: -30, to: Date()) ?? Date(),
            favoriteRecords: [
                DiscoModel(title: "Master of Puppets", artist: "Metallica", coverImageName: "master_of_puppets"),
                DiscoModel(title: "PetroDragonic Apocalypse...", artist: "King Gizzard and the...", coverImageName: "petrodragonic"),
                DiscoModel(title: "Ride the Lightning", artist: "Metallica", coverImageName: "ride_the_lightning"),
                DiscoModel(title: "Igor", artist: "Tyler, The Creator", coverImageName: "igor")
            ],
            myRecords: [
                DiscoModel(title: "Igor", artist: "Tyler, The Creator", coverImageName: "igor",
                           location: "Estante sala", locationColorHex: "F49AC2"),
                DiscoModel(title: "Igor", artist: "Tyler, The Creator", coverImageName: "igor",
                           location: "Caixa casa de Gabriel", locationColorHex: "34C759")
            ],
            wishlistRecords: [
                DiscoModel(title: "Igor", artist: "Tyler, The Creator", coverImageName: "igor")
            ]
        )
    }
}
