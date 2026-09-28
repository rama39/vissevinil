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
        TempPerfil(
            name: self.name,
            photoImageName: self.photoImageName,
            collectingSince: self.collectingSince
        )
    }
}
