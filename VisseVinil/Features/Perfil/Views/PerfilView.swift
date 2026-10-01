//
//  PerfilView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import SwiftUI
import SwiftData

struct PerfilView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var perfis: [PerfilModel]
    @Query private var todosOsDiscos: [DiscoModel]
    
    @Query var curtidas: [CurtidaModel]

    @State var editando: Bool = false
    @State var profileRef: PerfilModel? = nil

    // Controla qual tela será aberta ao tocar no título de uma seção.
    @State private var destino: PerfilDestino?

    // Discos marcados como favoritos pelo coração.
    private var discosFavoritos: [DiscoModel] {
        todosOsDiscos.filter { $0.favorito }
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
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                if let profile = perfis.first {
                    ScrollView {
                        VStack(spacing: 32) {
                            ProfileHeaderView(profile: profile) {
                                editando = true
                                profileRef = profile
                            }

                            // MARK: - Discos favoritos

                            VStack(alignment: .leading, spacing: 14) {
                                Text("Discos favoritos")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 20)

                                if !discosFavoritos.isEmpty {
                                    DiscosFavCarrossel(records: discosFavoritos)
                                }
                            }

                            // MARK: - Meus Discos

                            if !meusDiscos.isEmpty {
                                RecordSectionView(
                                    title: "Meus Discos",
                                    records: meusDiscos,
                                    showLocation: true
                                ) {
                                    destino = .meusDiscos
                                }
                            }
                            
                            // MARK: - Curtidos

                            
                            //if !curtidos.isEmpty {
                                CurtidaSectionView(
                                    title: "Curtidos",
                                    records: curtidas
                                ) {
                                    destino = .curtidos
                                }
                            //}

                            
                            // MARK: - Wishlist

                            if !wishlist.isEmpty {
                                RecordSectionView(
                                    title: "Wishlist",
                                    records: wishlist
                                ) {
                                    destino = .wishlist
                                }
                            }

                            // MARK: - Curtidos

                          
                        }
                        .padding(.top, 12)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationDestination(item: $destino) { destino in
                switch destino {
                case .meusDiscos:
                    ColecaoPesquisaView()

                case .wishlist:
                    TelaGenericaView(texto: "Wishlist")

                case .curtidos:
                    TelaGenericaView(texto: "Curtidos")
                }
            }
            .onAppear {
                // Só cria um perfil se ainda não existir nenhum salvo.
                guard perfis.isEmpty else { return }
                modelContext.insert(PerfilModel())
            }
            .fullScreenCover(isPresented: $editando) {
                EditPerfilView(
                    perfil: $profileRef,
                    editando: $editando
                )
            }
        }
    }
}

// MARK: - Destinos da navegação

private enum PerfilDestino: Hashable {
    case meusDiscos
    case wishlist
    case curtidos
}

// MARK: - Preview

#Preview {
    PerfilView()
        .modelContainer(for: appSchema, inMemory: true)
}
