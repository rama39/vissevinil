//
//  AddDiscoView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 20/09/26.
//

import SwiftUI
import SwiftData

struct AddDiscoView: View {
    @Environment(\.modelContext) private var modelContext
    func save() { if modelContext.hasChanges { try? modelContext.save() } }
    @Query private var discos: [DiscoModel]
    
    @Bindable var caixa: CaixaModel
    @Binding var adicionandoDisco: Bool
    
    var body: some View {
        List(discos) {disco in
            let contains = caixa.discos.contains(disco)
            if !contains {
                Button {
                    disco.caixa = caixa
                    save()
                    adicionandoDisco = false
                } label: {
                    ColecaoPesquisaRow(disco: disco)
                }
            }
        }
    }
}

//#Preview {
//    AddDiscoView()
//}
