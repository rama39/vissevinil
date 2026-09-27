//
//  guessThumb.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 19/09/26.
//

import Foundation
import SwiftUI

func guessThumb(_ thumbData: Data?) -> some View {
    Group {
        if let thumbImage = renderThumb(thumbData) {
            thumbImage
                .resizable()
                .scaledToFit()
        } else {
            noThumb
        }
    }
}
