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
    
    // Disco selecionado para abrir o DiscoView.
    @State private var discoSelecionado: DiscoModel?
    
    @State private var masterSelecionado: Int?

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
                            ProfileHeaderView(profile: profile)

                            // MARK: - Discos favoritos

                            if discosFavoritos.isEmpty {
                                secaoVazia(titulo: "Discos Favoritos", coisinha: .favoritos)
                            } else {
                                VStack(alignment: .leading, spacing: 14) {
                                    Text("Discos Favoritos")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(.primary)
                                        .padding(.horizontal, 20)
                                        .accessibilityAddTraits(.isHeader)

                                    // Capa do centro abre o disco (pela navegação desta tela)
                                    DiscosFavCarrossel(records: discosFavoritos) { disco in
                                        discoSelecionado = disco
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                            }

                            // MARK: - Meus Discos

                            if meusDiscos.isEmpty {
                                secaoVazia(titulo: "Meus Discos", coisinha: .meusDiscos)

                            } else {
                                RecordSectionView(
                                    title: "Meus Discos",
                                    records: meusDiscos,
                                    showLocation: true,
                                    onSeeAllTapped: {
                                        destino = .meusDiscos
                                    },
                                    onRecordTapped: { disco in
                                        discoSelecionado = disco
                                    }
                                )
                            }

                            // MARK: - Curtidos

                            if curtidas.isEmpty {
                                secaoVazia(titulo: "Curtidos", coisinha: .discosCurtidos)

                            } else {
                                CurtidaSectionView(
                                    title: "Curtidos",
                                    records: curtidas,
                                    onSeeAllTapped: {
                                        destino = .curtidos
                                    }, onRecordTapped: { curtida in
                                        if let masterID = curtida.master_id {
                                            masterSelecionado = masterID
                                        }
                                    }
                                )
                            }

                            // MARK: - Contato

                            contato
                                .padding(.top, 40)
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
                        .navigationTitle("Meus Discos")

                case .curtidos:
                    CurtidasListView()
                        .navigationTitle("Curtidos")
                }
            }
            
            .navigationDestination(item: $masterSelecionado) { masterID in
                MasterView(master_id: masterID)
            }
            
            .navigationDestination(item: $discoSelecionado) { disco in
                DiscoView(disco: disco)
            }
            
            
            // Título e ação no lugar padrão da barra (antes eram desenhados à mão no cabeçalho)
            .navigationTitle("Perfil")
            // Sempre o título pequeno, centralizado na barra
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if let profile = perfis.first {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Editar") {
                            profileRef = profile
                            editando = true
                        }
                    }
                }
            }
            .onAppear {
                // Só cria um perfil se ainda não existir nenhum salvo.
                guard perfis.isEmpty else { return }
                modelContext.insert(PerfilModel())
            }
            // Formulário curto: sheet (a HIG reserva tela cheia pra tarefas longas/imersivas)
            .sheet(isPresented: $editando) {
                EditPerfilView(
                    perfil: $profileRef,
                    editando: $editando
                )
            }
        }
    }

    /// Rodapé discreto com os canais de contato (os links abrem o Mail e o Instagram).
    /// Pequeno e apagado de propósito: está ali pra quem procurar, sem chamar atenção.
    private var contato: some View {
        VStack(spacing: 2) {
            Text("Precisa falar com a gente?")
                .fontWeight(.semibold)
            // Links na cor do app (vinho)
            Text("Mande um e-mail para [vissevinil@gmail.com](mailto:vissevinil@gmail.com) ou fale com a gente no Instagram [@vissevinil](https://instagram.com/vissevinil).")
        }
        .font(.caption2)
        .foregroundStyle(.tertiary)
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 32)
    }

    /// Título da seção (sem seta/botão — ainda não há nada pra abrir) +
    /// o estado vazio correspondente, logo abaixo.
    @ViewBuilder
    private func secaoVazia(titulo: String, coisinha: Componente) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(titulo)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
                .padding(.horizontal, 20)
                .accessibilityAddTraits(.isHeader)

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
