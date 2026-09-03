//
//  Utils.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import Foundation
import SwiftData
import SwiftUI

enum TipoEvento: String, Codable {
    case adicionou
    case tirouParaOuvir
    case comentou
}

struct RGBAColor: nonisolated Codable, Sendable {
    var r: UInt8
    var g: UInt8
    var b: UInt8
    var a: UInt8
    
    @MainActor
    func getColor(colorScheme: ColorScheme) -> Color {
        return Color(self)
    }
}

extension Color {
    init(_ rgba: RGBAColor?) {
        if let rgba {
            self.init( .sRGB,
                red: Double(rgba.r) / 255.0,
                green: Double(rgba.g) / 255.0,
                blue:  Double(rgba.b) / 255.0,
                opacity: Double(rgba.a) / 255.0
            )
        } else { self.init(.black) }
    }
    var toRGBA: RGBAColor {
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        uiColor.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        func clampI(_ i: CGFloat) -> UInt8 {UInt8(max(0, min(1, i)) * 255)}
        return RGBAColor ( r: clampI(r), g: clampI(g), b: clampI(b), a: clampI(a) )
    }
}

extension Caixa {
    var cor: Color {
        get { Color(rgba) }
        set { rgba = newValue.toRGBA }
    }
}
