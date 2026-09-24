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
    @Query var discos: [_DiscoModel]
    
    @Binding var discosFavoritos: [_DiscoModel]
    @Binding var adicionandoDisco: Bool
    @State var pesquisa: String = ""
    
    var body: some View {
        
        NavigationStack{
            List(discos.filter({disco in
                pesquisa.isEmpty ||
                disco.title.localizedCaseInsensitiveContains(pesquisa)
            })) {disco in
                HStack {
                    Button {
                        disco.favorito.toggle()
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
//            .toolbar{
//                ToolbarItem (placement: .topBarLeading){
//                    Button(role: .cancel) {
//                        adicionandoDisco = false
//                    } label: {
//                        Image(systemName: "xmark")
//                    }
//
//                }
            .searchable(text: $pesquisa)
            }
            
        }
    }


#Preview {
    AddFavoritoView(discosFavoritos: .constant([]), adicionandoDisco: .constant(true))
}
