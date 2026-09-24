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
    @Query private var todosOsDiscos: [DiscoModel]

    @State var editando: Bool = false
    @State var profileRef: PerfilModel? = nil

    // TEMPORÁRIO: 4 discos do Bob Marley, até o onboarding deixar o usuário
    // escolher os favoritos de verdade. Ver DiscosFavoritosMock.swift.
    private var discosFavoritos: [DiscoModel] {
        todosOsDiscos.filter({ disco in disco.favorito })
    }
    // Discos que já fazem parte da coleção (não estão na wishlist).
    private var meusDiscos: [DiscoModel] {
        todosOsDiscos.filter { !$0.wishlist }
    }
    // Discos que o usuário quer adquirir.
    private var wishlist: [DiscoModel] {
        todosOsDiscos.filter { $0.wishlist }
    }

    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.97, blue: 0.95).ignoresSafeArea()

            if let profile = perfis.first {
                ScrollView {
                    VStack(spacing: 32) {
                        ProfileHeaderView(profile: profile) {
                            onEditTapped: do {
                                editando = true
                                profileRef = profile
                            }
                        }

                        VStack(alignment: .leading, spacing: 14) {
                            Text("Discos favoritos")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color(red: 0.60, green: 0.38, blue: 0.20))
                                .padding(.horizontal, 20)

                                if !discosFavoritos.isEmpty {
                                DiscosFavCarrossel(records: discosFavoritos)
                            }
                        }

                        if !meusDiscos.isEmpty {
                            RecordSectionView(title: "Meus Discos", records: meusDiscos, showLocation: true) {
                                // TODO: navegar para a lista completa de discos do usuário
                            }
                        }

                        if !wishlist.isEmpty {
                            RecordSectionView(title: "Wishlist", records: wishlist) {
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
            modelContext.insert(PerfilModel())
        }
        .fullScreenCover(isPresented: $editando, content: {
            EditPerfilView(perfil: $profileRef, editando: $editando)
        })
    }
}
