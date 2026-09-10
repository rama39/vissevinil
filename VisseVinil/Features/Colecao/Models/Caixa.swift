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
    var rgba: RGBAColor? = nil
    
    var discos: [Disco] = []
    
    init() {
    }
}
