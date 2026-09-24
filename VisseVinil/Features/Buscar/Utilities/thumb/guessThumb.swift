//
//  guessThumb.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 19/09/26.
//

import Foundation
import SwiftUI

func guessThumb(_ thumbData: Data?) -> Image {
    if let thumbImage = renderThumb(thumbData) {
        thumbImage
//                AsyncImage(url: url) { image in
//                    image
//                        .resizable()
//                        .scaledToFit()
//                        .frame(width: 100, height: 100)
//                } placeholder: {
//                    ProgressView()
//                }
//                .clipShape(RoundedRectangle(cornerRadius: 8))
    } else {
        Image(systemName: "play.square")
    }
}
