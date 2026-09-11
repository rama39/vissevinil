//
//  getColor.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 11/09/26.
//

import SwiftUI

extension Caixa {
    var cor: Color {
        get { Color(rgba) }
        set { rgba = newValue.toRGBA }
    }
}
