//
//  a.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 11/09/26.
//

import SwiftUI

extension RGBAColor {
    @MainActor
    func getColor(colorScheme: ColorScheme) -> Color {
        return Color(self)
    }
}
