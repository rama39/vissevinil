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
    @Query var discos: [DiscoModel]
    
    @Binding var discosFavoritos: [DiscoModel]
    @Binding var adicionandoDisco: Bool
    @State var pesquisa: String = ""
    
    var body: some View {
        
        NavigationStack{
            let discosPesquisados = discos
                .filter({disco in
                pesquisa.isEmpty ||
                disco.title.localizedCaseInsensitiveContains(pesquisa)
            })
            List(discosPesquisados) {disco in
                HStack {
                    Button {
                        if !disco.favorito {
                            if discos.filter({disco in disco.favorito}).count < 4 {
                                disco.favorito = true
                            }
                        }
                        else {
                            disco.favorito = false
                        }
                    } label: {
                        Image(systemName: (disco.favorito ? "checkmark.circle.fill": "circle"))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    }
                    ColecaoPesquisaRow(disco: disco)
                }
            }
            .navigationTitle("Adicionar discos favoritos")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $pesquisa)
            }
            
        }
    }


#Preview {
    AddFavoritoView(discosFavoritos: .constant([]), adicionandoDisco: .constant(true))
}
