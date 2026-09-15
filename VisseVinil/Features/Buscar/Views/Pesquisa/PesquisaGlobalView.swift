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
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(DiscogsGenre.allCases, id: \.self) { genero in
                            GeneroTagView(
                                genero: genero,
                                tagSelecionada: $tagSelecionada
                            )
                        }
                    }
                }.padding()
                .scrollIndicators(.hidden)
                // Exibição do status ou da listagem
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Buscando no Discogs...")
                    Spacer()
                } else if viewModel.releases.isEmpty {
                    Spacer()
                    Text("Nenhum vinil encontrado.")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List(viewModel.releases) { release in
                        NavigationLink {
                            ReleaseDetailView(release: release)
                        } label: {
                            ReleaseRow(release: release)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Pesquisar Discos")
            .searchable(text: $searchText, placement: .automatic, prompt: "Pesquisar Disco")
            
            .toolbarVisibility( .hidden, for: .tabBar)
            .onSubmit(of: .search, {
                Task {
                    try await viewModel.searchVinyl(query: searchText, tag: tagSelecionada)
                }
            })
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
