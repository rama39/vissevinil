//
//  InicioView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import SwiftUI
import SwiftData

struct InicioView: View {
    var body: some View {
        Text("Início")
    }
}

#Preview {
    InicioView()
        .modelContainer(for: appSchema, inMemory: true)
}
