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
        .frame(width: frame, height: frame)
        .clipShape(RoundedRectangle(cornerRadius: radius))
}
