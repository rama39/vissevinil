//
//  placeholder.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 26/09/26.
//

import SwiftUI

let placeholder: some View = RoundedRectangle(cornerRadius: 4)
    .fill( Color(uiColor: .secondarySystemBackground) )
    .frame(width: 70, height: 70)
    .overlay(Image(systemName: "music.note"))
