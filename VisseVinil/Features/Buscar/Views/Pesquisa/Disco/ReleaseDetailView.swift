//
//  ReleaseDetailView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 11/09/26.
//

import SwiftUI

struct ReleaseDetailView: View {
    let releaseId: Int
    @State private var releaseViewModel = DiscogsMasterViewModel()
    
    @State var discoAdicionado: DiscogsMasterResponse? = nil
    @State var tempMaster: DiscogsMasterResponse? = nil
    
    var body: some View {
        List {
            if releaseViewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView("Carregando disco...")
                    Spacer()
                }
                .listRowSeparator(.hidden)
            } else if releaseViewModel.master == nil {
                HStack {
                    Spacer()
                    Text("Erro carregando vinil.")
                        .foregroundColor(.gray)
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
            else if let master = releaseViewModel.master {
                Group {
                    MasterImageView(images: master.images)
                        .listRowSeparator(.hidden)
                    Text(master.title ?? "")
                        .listRowSeparator(.hidden)
                    Text(master.artists?[0].name ?? "")
                    Section("Informações do disco") {
                        InfoRow(title: "Título", value: master.title)
                        InfoRow(title: "Artista", value: master.artists?[0].name)
                        InfoRow(title: "Lançamento", value: String(master.year ?? 0))
                        InfoRow(title: "Gêneros", value: master.genres?.joined(separator: ", "))
                        InfoRow(title: "Subgêneros", value: master.styles?.joined(separator: ", "))
                    }
                }.onAppear {tempMaster = master}
            }
        }
        .listStyle(.plain)
        
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    discoAdicionado = tempMaster
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        
        .fullScreenCover(item: $discoAdicionado) { master in
            AdicionandoDiscoView(discoAdicionado: $discoAdicionado, master: master)
        }
        
        .onAppear {
            Task {
                await releaseViewModel.requestVinyl(id: releaseId)
            }
        }
    }
}

// do not use. old. remove later
/*struct _ReleaseDetailView: View {
    let releaseId: Int
    @State private var releaseViewModel = DiscogsMasterViewModel()

    var body: some View {
        List {
            if releaseViewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView("Carregando disco...")
                    Spacer()
                }
                .listRowSeparator(.hidden)
            } else if releaseViewModel.master == nil {
                HStack {
                    Spacer()
                    Text("Erro carregando vinil.")
                        .foregroundColor(.gray)
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
            else if let master = releaseViewModel.master,
                    let version = releaseViewModel.masterversion,
                    let release = version.versions?[0] {
                // MARK: - Cabeçalho com Capa e Título
                Section {
                    HStack(alignment: .top, spacing: 16) {
                        if let thumbUrl = release.thumb,
                            let url = URL(string: thumbUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            Image(systemName: "music.note.house")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.gray)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text(release.title ?? "Título Desconhecido")
                                .font(.title2)
                                .bold()
                            
                            if let year = master.year {
                                Text("Ano: \(year)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                // MARK: - Informações Básicas
                Section(header: Text("Informações do Lançamento")) {
                    InfoRow(title: "País", value: release.country)
                    InfoRow(title: "Formato", value: release.format)
                    InfoRow(title: "Selo (Label)", value: release.label)
                    InfoRow(title: "Catálogo Nº", value: release.catno)
                    //InfoRow(title: "Tipo", value: release.type?.capitalized)
                    //InfoRow(title: "Código de Barras", value: release.barcode?.joined(separator: ", "))
                }
                
                // MARK: - Gêneros e Estilos
                Section(header: Text("Gêneros e Estilos")) {
                    InfoRow(title: "Gênero", value: master.genres?.joined(separator: ", "))
                    InfoRow(title: "Estilo", value: master.styles?.joined(separator: ", "))
                }
                
                // MARK: - Dados da Comunidade
                if let community = release.stats?.community {
                    Section(header: Text("Comunidade Discogs")) {
                        HStack {
                            Label("\(community.inCollection ?? 0) têm", systemImage: "record.circle")
                            Spacer()
                            Label("\(community.inWantlist ?? 0) querem", systemImage: "heart")
                        }
                        .font(.callout)
                        .foregroundColor(.secondary)
                    }
                }
                
                // MARK: - Links Úteis
                Section(header: Text("Links Externos")) {
                    if let uri = master.uri, let url = URL(string: "https://www.discogs.com\(uri)") {
                        Link(destination: url) {
                            Label("Ver no Discogs (Web)", systemImage: "safari")
                        }
                    }
                    
                    if let resourceURL = release.resourceURL, let url = URL(string: resourceURL) {
                        Link(destination: url) {
                            Label("URL da API", systemImage: "link")
                        }
                    }
                }
            }
        }
        .navigationTitle("Detalhes")
        .navigationBarTitleDisplayMode(.inline)
        
        .onAppear {
            Task {
                await releaseViewModel.requestVinyl(id: releaseId)
            }
        }
    }
} */


#Preview {
    NavigationStack {
        ReleaseDetailView(releaseId: 1000)
    }
}
