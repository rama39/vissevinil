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

    // Discos que já fazem parte da coleção.
    private var meusDiscos: [DiscoModel] {
        todosOsDiscos.filter { !$0.wishlist }
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

                            if discosFavoritos.isEmpty {
                                secaoVazia(titulo: "Discos favoritos", coisinha: .favoritos)
                            } else {
                                VStack(alignment: .leading, spacing: 14) {
                                    Text("Discos favoritos")
                                        .font(.system(size: 20, weight: .semibold))
                                        .foregroundStyle(.primary)
                                        .padding(.horizontal, 20)
                                    
                                        .padding(0.5)


                                    DiscosFavCarrossel(records: discosFavoritos)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                            }

                            // MARK: - Meus Discos

                            if meusDiscos.isEmpty {
                                secaoVazia(titulo: "Meus Discos", coisinha: .meusDiscos)
                                
                                    .padding(0.5)

                            } else {
                                RecordSectionView(
                                    title: "Meus Discos",
                                    records: meusDiscos,
                                    showLocation: true
                                ) {
                                    destino = .meusDiscos
                                }
                            }

                            // MARK: - Curtidos

                            if curtidas.isEmpty {
                                secaoVazia(titulo: "Curtidos", coisinha: .discosCurtidos)
                                    .padding(0.5)

                            } else {
                                CurtidaSectionView(
                                    title: "Curtidos",
                                    records: curtidas
                                ) {
                                    destino = .curtidos
                                }
                            }
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

                case .curtidos:
                    CurtidasListView()
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

    /// Título da seção (sem seta/botão — ainda não há nada pra abrir) +
    /// o estado vazio correspondente, logo abaixo.
    @ViewBuilder
    private func secaoVazia(titulo: String, coisinha: Componente) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(titulo)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 20)

            VazioView(coisinha: coisinha)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Destinos da navegação

private enum PerfilDestino: Hashable {
    case meusDiscos
    case curtidos
}

// MARK: - Preview

#Preview {
    PerfilView()
        .modelContainer(for: appSchema, inMemory: true)
}
