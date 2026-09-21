//
//  toData.swift
//  VisseVinil
//
//  Created by Maria Eduarda Marrocos Honda on 21/09/26.
//

import Foundation

extension TempPerfil {
    // MARK: - Dados básicos do usuário
    func toData(perfil: PerfilModel) {
        perfil.name = self.name
        perfil.photoImageName  = self.photoImageName
        perfil.collectingSince = self.collectingSince
        perfil.favoriteRecords = self.favoriteRecords
        perfil.myRecords = self.myRecords
        perfil.wishlistRecords = self.wishlistRecords
    }
}
