//
//  TestSearchView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 07/09/26.
//

import SwiftUI

struct TestSearchView: View {
    @State private var viewModel = DiscogsViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack {
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
                        HStack(alignment: .top, spacing: 12) {
                            // Carrega a imagem da capa de forma assíncrona
                            if let thumbUrlString = release.thumb, let thumbUrl = URL(string: thumbUrlString) {
                                AsyncImage(url: thumbUrl) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Color.gray.opacity(0.3)
                                }
                                .frame(width: 60, height: 60)
                                .cornerRadius(4)
                                .clipped()
                            } else {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 60, height: 60)
                                    .overlay(Image(systemName: "music.note"))
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(release.title ?? "Disco")
                                    .font(.headline)
                                    .lineLimit(2)
                                
                                HStack {
                                    if let year = release.year {
                                        Text(year)
                                    }
                                    if let country = release.country {
                                        Text("•  \(country)")
                                    }
                                }
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Pesquisar Discos")
            .searchable(text: $searchText, placement: .automatic, prompt: "Pesquisar Disco")
            
            .toolbarVisibility( .hidden, for: .tabBar)
            .onSubmit(of: .search, {
                Task {
                    try await viewModel.searchVinyl(query: searchText)
                }
            })
        }
    }
}

#Preview {
    TabView {
        Tab("Explorar", systemImage: "magnifyingglass") {
            TestSearchView()
        }
    }
}
