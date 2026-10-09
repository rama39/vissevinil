//
//  InfoButton.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 08/10/26.
//

import SwiftUI

struct InfoButton: View {
    
    enum Tipo {
        case capa
        case disco
    }
    
    @State private var showInfo = false
    let tipo: Tipo
    
    var body: some View {
        Button {
            showInfo.toggle()
        } label: {
            Image(systemName: "questionmark.circle")
                .foregroundStyle(.secondary)
                .frame(width: 25, height: 25)
                .accessibilityLabel("Mais informação")
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showInfo) {
            let estadosCapa = Array(titleEstados.keys).sorted(by: {$0.rawValue < $1.rawValue})
            let estadosDisco = Array(estadosCapa.dropFirst(2))
            let estados = tipo == .disco ? estadosDisco : estadosCapa
            let info = tipo == .disco ? infoTextDisco : infoTextCapa
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(estados, id: \.self) { estado in
                            HStack {
                                Text("**\(titleEstados[estado] ?? "")**: \(info[estado] ?? "")")
                            }
                            //.frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding()
                }
                //.presentationCompactAdaptableSizes([.compact])
                //.presentationCompactAdaptation(.popover)
                .presentationDetents([.fraction(0.3), .large])
                .navigationTitle(tipo == .disco ? "Estado do Disco" : "Estado da Capa")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    InfoButton(tipo: .disco)
}
