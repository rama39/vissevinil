//
//  frameThumb.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 19/09/26.
//

import SwiftUI

func frameThumb(
    _ thumbData: Data?,
    frame: CGFloat = 70,
    radius: CGFloat = 8
) -> some View {
    guessThumb(thumbData)
        .resizable()
        .scaledToFit()
        .frame(width: frame, height: frame)
        .foregroundColor(.gray)
        .clipShape(RoundedRectangle(cornerRadius: radius))
}
