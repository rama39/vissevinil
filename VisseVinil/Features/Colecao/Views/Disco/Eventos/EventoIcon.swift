//
//  EventoIcon.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 01/10/26.
//

import SwiftUI

struct EventoIcon: View {
    let elementColor: Color
    let systemImage: String
    let iconSize: CGFloat
    var body: some View {
        Circle()
            .fill(elementColor)
            .frame(width: iconSize, height: iconSize)
            .overlay {
                Image(systemName: systemImage)
                    .resizable().scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.primary)
            }
    }
}
