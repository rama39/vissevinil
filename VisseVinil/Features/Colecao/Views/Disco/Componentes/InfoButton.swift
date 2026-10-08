//
//  InfoButton.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 08/10/26.
//

import SwiftUI

struct InfoButton: View {
    
    @State private var showInfo = false
    
    var body: some View {
        Button {
            showInfo.toggle()
        } label: {
            Image(systemName: "info.circle")
                .accessibilityLabel("More information")
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showInfo) {
            Text("""
                 ESTADO DO DISCO
                 • M: Impecável. Sem uso e sem marcas.
                 • NM: Quase perfeito. Sem chiados.
                 • VG+: Excelente. Marcas superficiais leves.
                 • VG: Marcas visíveis e chiado leve (não pula).
                 • G+: Desgastado. Chiados contínuos, mas audível.
                 • G: Muito usado. Ruído constante de fundo.
                 • F: Mau estado. Riscos que fazem a agulha pular.
                 • P: Danificado/Empenado. Inaudível.
            """)
                .padding()
                //.presentationCompactAdaptableSizes([.compact])
                //.presentationCompactAdaptation(.popover)
                .presentationDetents([.medium])
        }
    }
}

#Preview {
    InfoButton()
}
