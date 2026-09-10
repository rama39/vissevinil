//
//  MapaView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import SwiftUI
import SwiftData
import MapKit

struct MapaView: View {
    var body: some View {
        Map(initialPosition: .automatic)
    }
}

#Preview {
    MapaView()
        .modelContainer(for: appSchema, inMemory: true)
}
