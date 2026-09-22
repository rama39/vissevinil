//
//  toStruct.swift
//  VisseVinil
//
//  Created by Maria Eduarda Marrocos Honda on 22/09/26.
//

import Foundation

extension PerfilModel {
    // MARK: - Dados básicos do usuário
    func toStruct() ->TempPerfil {
        
        var perfil: TempPerfil = TempPerfil(name: "")
        
        perfil.name = self.name
        perfil.photoImageName  = self.photoImageName
        perfil.collectingSince = self.collectingSince
        perfil.favoriteRecords = self.favoriteRecords
        perfil.myRecords = self.myRecords
        perfil.wishlistRecords = self.wishlistRecords
        
        return perfil
    }
}

