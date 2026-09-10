//
//  InicioView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import SwiftUI
import SwiftData

struct BuscarView: View {
    
    
    
    var body: some View {
        NavigationStack {
            VStack {
                
            }
            .navigationTitle("Início")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    BuscarView()
        .modelContainer(for: appSchema, inMemory: true)
}
