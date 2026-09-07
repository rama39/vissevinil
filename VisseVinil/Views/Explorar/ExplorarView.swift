//
//  InicioView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import SwiftUI
import SwiftData

struct ExplorarView: View {
    
    
    
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
    ExplorarView()
        .modelContainer(for: appSchema, inMemory: true)
}
