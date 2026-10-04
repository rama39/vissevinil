//
//  TestSearchView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 07/09/26.
//

import SwiftUI

struct PesquisaGlobalView: View {
    @State private var searchViewModel = PesquisaGlobalViewModel()
    
    @State private var searchText = ""
    @State var tagSelecionada: DiscogsGenre? = nil
    @State var tipoSelecionado: TipoDeBusca = TipoDeBusca.disco
    
    @State private var isSearchPresented = true
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    if searchViewModel.naoPesquisou {
                        let text = tipoSelecionado == .disco ?
                        "Digite o nome de um disco que você busca para adicionar na sua coleção.":
                        "Digite o nome de um artista que você busca para adicionar seus discos na sua coleção"
                        Text(text)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .frame(height: 300)
                            .listRowSeparator(.hidden)
                    } else if !searchViewModel.isLoading,
                        searchViewModel.releases.isEmpty {
                        HStack {
                            Spacer()
                            Text("Nenhum vinil encontrado.")
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    } else {
                        ForEach(searchViewModel.releases) { master in //search filters for master vinyl versions
                            NavigationLink {
                                MasterView(master_id: master.id)
                            } label: {
                                SearchRow(release: master)
                            }
                            .onAppear {
                                if master.id == searchViewModel.releases[searchViewModel.releases.count-1].id {
                                    searchViewModel.movePage()
                                    search()
                                }
                            }
                        }
                    }
                    // Exibição do status ou da listagem
                    if searchViewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView("Buscando discos...")
                            Spacer()
                        }
                        .listRowSeparator(.hidden)
                    }
                } header: {
                    VStack {
                        HStack {
                            ForEach(TipoDeBusca.allCases, id: \.self) { tipo in
                                TipoTagView (
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
            .searchable(
                text: $searchText,
                isPresented: $isSearchPresented,
                placement: .automatic,
                prompt: tipoSelecionado == .disco ?
                        "Pesquisar Discos" : "Pesquisar Discos por Artista"
            )
            
            .listStyle(.plain)
            
            .onSubmit(of: .search) { resetSearch() }
            .onChange(of: tagSelecionada) { resetSearch() }
            .onChange(of: tipoSelecionado) { resetSearch() }
        }
    }
    private func search() {
        Task {
            await searchViewModel.search(
                query: searchText,
                tag: tagSelecionada,
                tipo: tipoSelecionado)
        }
    }
    private func resetSearch() {
        Task {
            await searchViewModel.resetSearch(
                query: searchText,
                tag: tagSelecionada,
                tipo: tipoSelecionado)
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
