//
//  DiscoModel.swift
//  VisseVinil
//
//  Created by Pedro Augusto Santos de Sousa on 16/09/26.
//

import SwiftUI

struct DiscoModel: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let artist: String
    /// Nome da imagem no Asset Catalog (ou, futuramente, URL da capa vinda do backend).
    let coverImageName: String
    /// Local de armazenamento físico do disco (relevante só para "Meus Discos").
    let location: String?
    /// Cor da bolinha de localização, guardada como hex porque Color não é Codable.
    let locationColorHex: String?

    init(id: UUID = UUID(),
         title: String,
         artist: String,
         coverImageName: String,
         location: String? = nil,
         locationColorHex: String? = nil) {
        self.id = id
        self.title = title
        self.artist = artist
        self.coverImageName = coverImageName
        self.location = location
        self.locationColorHex = locationColorHex
    }

    var locationColor: Color? {
        guard let locationColorHex else { return nil }
        return Color(hex: locationColorHex)
    }
}

extension Color {
    init(hex: String) {
        var value: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&value)

        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255
        )
    }
}
