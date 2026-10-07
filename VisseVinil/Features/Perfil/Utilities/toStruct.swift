//
//  toStruct.swift
//  VisseVinil
//
//  Created by Maria Eduarda Marrocos Honda on 22/09/26.
//

import Foundation

extension PerfilModel {
    // MARK: - Dados básicos do usuário
    func toStruct() -> TempPerfil {
        var temp = TempPerfil(
            name: self.name,
            photoImageName: self.imagePhotoName,
            collectingSince: self.collectingSince
        )
        temp.bordaDaFoto = self.bordaDaFoto
        return temp
    }
}
