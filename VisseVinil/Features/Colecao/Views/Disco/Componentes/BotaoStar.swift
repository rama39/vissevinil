//
//  BotaoStar.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 30/09/26.
//

import SwiftUI

struct BotaoStar: View {
    @Binding var stars: Int?
    let i: Int
    var body: some View {
        Button {
            stars = i
        } label: {
            Image(systemName: "star" + ((stars != nil && stars! >= i) ? ".fill" : ""))
                .resizable().scaledToFit()
                .frame(width:25, height: 25)
                .foregroundStyle(.amarelo)
        }.buttonStyle(.plain)
    }
}
