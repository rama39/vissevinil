//
//  DiscoSheetView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import SwiftUI
import SwiftData

struct DiscoView: View {
    @Bindable var discoSelecionado: Disco
    var body: some View {
        VStack {
            Text("Conteúdo do disco")
        }
        .navigationTitle(discoSelecionado.nome)
        .navigationBarTitleDisplayMode(.automatic)
            .presentationDetents([.large, .medium])
    }
}

#Preview {
    let container = try! ModelContainer(for: Disco.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    let mockDisco = Disco(posicao: 0)
    container.mainContext.insert(mockDisco)
    
    return NavigationStack {
        DiscoView(discoSelecionado: mockDisco)
    }
        .modelContainer(container)
}
