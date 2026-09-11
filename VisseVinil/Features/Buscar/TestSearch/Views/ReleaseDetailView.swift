//
//  ReleaseDetailView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 11/09/26.
//

import SwiftUI

struct ReleaseDetailView: View {
    let release: DiscogsRelease

    var body: some View {
        List {
            // MARK: - Cabeçalho com Capa e Título
            Section {
                HStack(alignment: .top, spacing: 16) {
                    if let thumbUrl = release.thumb, let url = URL(string: thumbUrl) {
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
                        
                        if let year = release.year {
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
                InfoRow(title: "Formato", value: release.format?.joined(separator: ", "))
                InfoRow(title: "Selo (Label)", value: release.label?.joined(separator: ", "))
                InfoRow(title: "Catálogo Nº", value: release.catno)
                InfoRow(title: "Tipo", value: release.type?.capitalized)
                InfoRow(title: "Código de Barras", value: release.barcode?.joined(separator: ", "))
            }
            
            // MARK: - Gêneros e Estilos
            Section(header: Text("Gêneros e Estilos")) {
                InfoRow(title: "Gênero", value: release.genre?.joined(separator: ", "))
                InfoRow(title: "Estilo", value: release.style?.joined(separator: ", "))
            }
            
            // MARK: - Dados da Comunidade
            if let community = release.community {
                Section(header: Text("Comunidade Discogs")) {
                    HStack {
                        Label("\(community.have) têm", systemImage: "record.circle")
                        Spacer()
                        Label("\(community.want) querem", systemImage: "heart")
                    }
                    .font(.callout)
                    .foregroundColor(.secondary)
                }
            }
            
            // MARK: - Links Úteis
            Section(header: Text("Links Externos")) {
                if let uri = release.uri, let url = URL(string: "https://www.discogs.com\(uri)") {
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
        .navigationTitle("Detalhes")
        .navigationBarTitleDisplayMode(.inline)
    }
}
