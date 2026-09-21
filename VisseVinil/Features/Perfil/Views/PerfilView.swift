//
//  PerfilView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.


import SwiftUI
import SwiftData

struct PerfilView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var perfis: [PerfilModel]
    
    @State var editando: Bool = false

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.97, blue: 0.95).ignoresSafeArea()

            if let profile = perfis.first {
                ScrollView {
                    VStack(spacing: 32) {
                        ProfileHeaderView(profile: profile) {
                            onEditTapped: do {editando = true}
                            // TODO: navegar para tela de edição de perfil
                        }

                        if !profile.favoriteRecords.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Discos favoritos")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(Color(red: 0.60, green: 0.38, blue: 0.20))
                                    .padding(.horizontal, 20)

                                DiscosFavCarrossel(records: profile.favoriteRecords)
                            }
                        }

                        if !profile.myRecords.isEmpty {
                            RecordSectionView(title: "Meus Discos", records: profile.myRecords, showLocation: true) {
                                // TODO: navegar para a lista completa de discos do usuário
                            }
                        }

                        if !profile.wishlistRecords.isEmpty {
                            RecordSectionView(title: "Wishlist", records: profile.wishlistRecords) {
                                // TODO: navegar para a wishlist completa
                            }
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear {
            // Só cria um perfil se ainda não existir nenhum salvo.
            guard perfis.isEmpty else { return }
            modelContext.insert(PerfilModel.exemplo)
        }
        .fullScreenCover(isPresented: $editando, content: {
            EditPerfilView(editando: $editando)
        })
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
