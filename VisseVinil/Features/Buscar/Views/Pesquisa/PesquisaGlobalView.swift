//
//  TestSearchView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 07/09/26.
//

import SwiftUI

struct PesquisaGlobalView: View {
    @State private var viewModel = DiscogsSearchViewModel()
    @State private var searchText = ""
    @State var tagSelecionada: DiscogsGenre? = nil
    @State var tipoSelecionado: TipoDeBusca = TipoDeBusca.disco
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    // Exibição do status ou da listagem
                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView("Buscando no Discogs...")
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    } else if viewModel.releases.isEmpty {
                        HStack {
                            Spacer()
                            Text("Nenhum vinil encontrado.")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    } else {
                        ForEach(viewModel.releases) { release in
                            NavigationLink {
                                ReleaseDetailView(release: release)
                            } label: {
                                ReleaseRow(release: release)
                            }
                        }
                    }
                } header: {
                    VStack {
                        HStack {
                            ForEach(TipoDeBusca.allCases, id: \.self) { tipo in
                                TipoDeBuscaView (
                                    tipo: tipo,
                                    tipoSelecionado: $tipoSelecionado
                                )
                            }
                        }
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(DiscogsGenre.allCases, id: \.self) { genero in
                                    GeneroTagView(
                                        genero: genero,
                                        tagSelecionada: $tagSelecionada
                                    )
                                }
                            }
                        }
                        .scrollIndicators(.hidden)
                    }
                }
            }
            .navigationTitle("Pesquisar Discos")
            .searchable(text: $searchText, placement: .automatic, prompt: "Pesquisar Disco")
            
            .listStyle(.plain)
            
            .onSubmit(of: .search) {
                Task {
                    try await viewModel.searchVinyl(query: searchText, tag: tagSelecionada)
                }
            }
            .onChange(of: tagSelecionada) {
                Task {
                    try await viewModel.searchVinyl(query: searchText, tag: tagSelecionada)
                }
            }
        }
    }
}

#Preview {
    TabView {
        Tab("Buscar", systemImage: "magnifyingglass") {
            PesquisaGlobalView()
        }
    }
}
