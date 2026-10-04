//
//  placeholder.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 26/09/26.
//

import SwiftUI

let noThumb: some View =
    RoundedRectangle(cornerRadius: 8, style: .continuous)
        .fill( Color(uiColor: .secondarySystemBackground) )
        .overlay( Image(systemName: "music.note") )
        .aspectRatio(1, contentMode: .fit)

func noThumb(frame: CGFloat = 70) -> some View {
    noThumb
        .frame(width: frame, height: frame)
}
