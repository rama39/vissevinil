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
    
    var tempPerfil = PerfilModel(name: "Marrocos")
    
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
                        TextField(tempPerfil.name, text: .constant(""))
                      
                        
                    }
                }
           }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .confirm, action: {
                        print("Pressed")
                    }, label: {
                        Image(systemName:"checkmark")
                    } )
                    
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        print("Pressed")
                    }, label: {
                        Image(systemName:"checkmark")
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
    EditPerfilView()
}
