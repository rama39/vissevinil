//
//  FormOnboarding.swift
//  VisseVinil
//
//  Created by Maria Eduarda Marrocos Honda on 18/09/26.
//

import SwiftUI
import SwiftData

struct EditPerfilView: View {
   // criar perfil e substituior o de exemplo
    @Environment(\.modelContext) private var modelContext
    @Query private var perfis: [PerfilModel]
    
    @State var tempPerfil = TempPerfil(name: "")
    @Binding var editando: Bool
    
    var body: some View {
        NavigationStack{
            VStack{
                ZStack {
                    Color.gray.opacity(0.2)
                    Image(tempPerfil.photoImageName)
                }
                .frame(width: 130, height: 130)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.gray)
                )
                Button (action:{
                    print("oie")
                }, label: {
                    Text("Editar Foto")
                })
                    .buttonStyle(.borderedProminent)
                Form{
                    Section{
                        TextField(tempPerfil.name, text: $tempPerfil.name)
                      
                        
                    }
                }
           }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .confirm, action: {
                        let userPerfil = perfis.first
                        // if userPerfil != nil
                        // let novouserPerfil = userPerfil!
                        if let userPerfil { // verifica se conseguiu/existe um user perfil
                            tempPerfil.toData(perfil: userPerfil)
                        }
                        editando = false
                    }, label: {
                        Image(systemName:"checkmark")
                    } )
                    
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        editando = false
                    }, label: {
                        Image(systemName:"xmark")
                    } )
                    
                }
            }
            
        }
        .onAppear {
            // Só cria um perfil se ainda não existir nenhum salvo.
            guard perfis.isEmpty else { return }
            modelContext.insert(PerfilModel.exemplo)
        }
        
    }
}

#Preview {
    @Previewable @State var tabSelecionada: VisseVinilTabs = .perfil
    
        TabView(selection: $tabSelecionada) {
            Tab("Mapa", systemImage: "map", value: .mapa) {
                MapaView()
            }
            Tab("Buscar", systemImage: "magnifyingglass", value: .buscar) {
                BuscarView()
            }
            Tab("Coleção", systemImage: "music.note.square.stack.fill", value: .colecao) {
                ColecaoView()
            }
            Tab("Perfil", systemImage: "person", value: .perfil) {
                PerfilView()
            }
        }
        .modelContainer(for: appSchema, inMemory: true)

}
