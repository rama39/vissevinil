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
        perfil.imagePhotoName = self.photoImageName
        perfil.collectingSince = self.collectingSince
        perfil.bordaDaFoto = self.bordaDaFoto
    }
}
