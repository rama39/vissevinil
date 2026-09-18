//
//  MasterDetailView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 11/09/26.
//

import SwiftUI

struct MasterView: View {
    let master_id: Int //snake case to match API documentation
    @State private var masterViewModel = MasterViewModel()
    
    @State var discoAdicionado: MasterResponse? = nil
    @State var tempMaster: MasterResponse? = nil
    
    var body: some View {
        List {
            if masterViewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView("Carregando disco...")
                    Spacer()
                }
                .listRowSeparator(.hidden)
            } else if masterViewModel.master == nil {
                HStack {
                    Spacer()
                    Text("Erro carregando vinil.")
                        .foregroundColor(.gray)
                    Spacer()
                }
                .listRowSeparator(.hidden)
            }
            else if let master = masterViewModel.master {
                Group {
                    MasterImageView(images: master.images)
                        .listRowSeparator(.hidden)
                    Text(master.title ?? "")
                        .listRowSeparator(.hidden)
                    Text(master.artists?[0].name ?? "")
                    Section("Informações do disco") {
                        MasterInfoRow(title: "Título", value: master.title)
                        MasterInfoRow(title: "Artista", value: master.artists?[0].name)
                        MasterInfoRow(title: "Lançamento", value: String(master.year ?? 0))
                        MasterInfoRow(title: "Gêneros", value: master.genres?.joined(separator: ", "))
                        MasterInfoRow(title: "Subgêneros", value: master.styles?.joined(separator: ", "))
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
            VersionSelectView(master: master, discoAdicionado: $discoAdicionado)
        }
        
        .onAppear {
            Task {
                await masterViewModel.requestMaster(id: master_id)
            }
        }
    }
}


#Preview {
    NavigationStack {
        MasterView(master_id: 1000)
    }
}
