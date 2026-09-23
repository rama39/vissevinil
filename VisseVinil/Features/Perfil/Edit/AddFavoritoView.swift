//
//  AddFavoritoView.swift
//  VisseVinil
//
//  Created by Maria Eduarda Marrocos Honda on 22/09/26.
//

import SwiftUI
import SwiftData

struct AddFavoritoView: View {
    @Environment(\.modelContext) private var modelContext
    func save() { if modelContext.hasChanges { try? modelContext.save() } }
    
    @Binding var discosFavoritos: [_DiscoModel]
    @Binding var adicionandoDisco: Bool
    
    var body: some View {
        List(discosFavoritos) {disco in
            HStack {
                //let contains = caixa.discos.contains(disco)
//                if !contains {
//                    Button {
//                        
//                    } label: {
//                        //ColecaoPesquisaRow(disco: disco)
//                    }
//                }
                ColecaoPesquisaRow(disco: disco)
            }
        }
    }
}

//#Preview {
//    AddFavoritoView()
//}
