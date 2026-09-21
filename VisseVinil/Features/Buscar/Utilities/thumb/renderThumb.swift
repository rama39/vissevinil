//
//  renderThumb.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 19/09/26.
//

import Foundation
import SwiftUI

func renderThumb(_ thumbData: Data?) -> Image? {
    if let thumbData,
       let uiImage = UIImage(data: thumbData) {
        return Image(uiImage: uiImage)
    }
    return nil
}
