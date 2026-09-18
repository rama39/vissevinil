//
//  Data.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import Foundation
import SwiftData

@Model
final class Caixa {
    var title: String
    var rgba: RGBAColor
    
    @Relationship(deleteRule: .noAction)
    var discos: [DiscoModel] = []
    
    init(title: String, rgba: RGBAColor) {
        self.title = title
        self.rgba = rgba
    }
}
