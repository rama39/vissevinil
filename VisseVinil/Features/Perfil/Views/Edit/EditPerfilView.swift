//
//  FormOnboarding.swift
//  VisseVinil
//
//  Created by Maria Eduarda Marrocos Honda on 18/09/26.
//

import SwiftUI
import SwiftData
import PhotosUI

struct EditPerfilView: View {
   // criar perfil e substituior o de exemplo
    @Environment(\.modelContext) private var modelContext
    @Query private var perfis: [PerfilModel]
    
    @State private var date = Date()
    @State var tempPerfil = TempPerfil(name: "")
    @Binding var perfil: PerfilModel?
    @State private var tempimagePhotoName: PhotosPickerItem?
    @Binding var editando: Bool
    
    @State var escolhendoFavoritos = false
    
    var body: some View {
        NavigationStack{
            VStack{
                ZStack {
                    Color.gray.opacity(0.2)
                    if let profileImage = tempPerfil.photoImageName, let uiImage = UIImage(data: profileImage) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        // Placeholder enquanto não há asset cadastrado
                        ZStack {
                            Color.gray.opacity(0.2)
                            Image(systemName: "opticaldisc.fill")
                                .resizable()
                                .frame(width: 115, height: 115)
                        }
                    }
                }
                .frame(width: 130, height: 130)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(Color.gray)
                )
                PhotosPicker(selection: $tempimagePhotoName, matching: .images){
                    Label("Editar foto", systemImage: "pencil")
                }
                .buttonStyle(.borderedProminent)
                .padding ()
                .onChange(of: tempimagePhotoName){
                    Task{
                        await SalvarFoto()
                    }
                }
                Form{
                    Section{
                        TextField("Nome", text: $tempPerfil.name)
                        DatePicker("Data de início da coleção", selection: $date, displayedComponents: [.date])
                        
                    }
                    Section{ // fazer como o add disco view - botao quw adiciona a listinha que o
                        EscolherFavoritos(adicionarFavorito: $escolhendoFavoritos)
                    }
                }
           }
            .navigationTitle("Perfil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .confirm, action: {
                        if let perfil { // verifica se conseguiu/existe um user perfil
                            tempPerfil.toData(perfil: perfil)
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
            .sheet(isPresented: $escolhendoFavoritos ){
                AddFavoritoView(discosFavoritos: .constant([]), adicionandoDisco: $escolhendoFavoritos)
            
            }
        }
        .onAppear {
            if let perfil {
                tempPerfil = perfil.toStruct()
            }
        }
        
    }
    
    private func SalvarFoto() async {
        guard let tempimagePhotoName,
              let data = try? await tempimagePhotoName.loadTransferable(type: Data.self)
        else { return }
        
        tempPerfil.photoImageName = data
    }
}

#Preview {
//    @Previewable @State var tabSelecionada: VisseVinilTabs = .perfil
//
//        TabView(selection: $tabSelecionada) {
//            Tab("Mapa", systemImage: "map", value: .mapa) {
//                MapaView()
//            }
//            Tab("Buscar", systemImage: "magnifyingglass", value: .buscar) {
//                BuscarView()
//            }
//            Tab("Coleção", systemImage: "music.note.square.stack.fill", value: .colecao) {
//                ColecaoView()
//            }
//            Tab("Perfil", systemImage: "person", value: .perfil) {
//                PerfilView()
//            }
//        }
//        .modelContainer(for: appSchema, inMemory: true)
    
    @Previewable @State var a: Bool = true
    TabView {
        Tab("Perfil", systemImage: "perfil") {
            //EditPerfilView(editando: $a)
            PerfilView()
        }
    }
    .modelContainer(for: appSchema, inMemory: true)

}
