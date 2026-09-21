//
//  Data.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import Foundation
import SwiftData

@Model
final class CaixaModel {
    var title: String
    var rgba: RGBAColor
    
    @Relationship(deleteRule: .nullify, inverse: \_DiscoModel.caixa)
    var discos: [_DiscoModel] = []
    
    init(title: String, rgba: RGBAColor) {
        self.title = title
        self.rgba = rgba
    }
}
