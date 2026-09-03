//
//  Item.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
