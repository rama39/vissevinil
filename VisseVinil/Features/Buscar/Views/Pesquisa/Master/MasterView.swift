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
    
    @State var selectedMaster: MasterResponse? = nil
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
                    VStack(alignment: .leading, spacing: 0) {
                        MasterImageView(images: master.images)
                            .padding(.bottom)
                        HStack {
                            MasterIsSavedView(master_id: master.id ?? 0)
                            // TODO: fazer botoes
                            Image(systemName: "heart").resizable().scaledToFit().frame(width:25, height: 25)
                                .padding(.trailing)
                            Image(systemName: "bookmark").resizable().scaledToFit().frame(width:25, height: 25)
                        }
                        .padding(.bottom)
                        Text(master.title ?? "")
                            .font(.title2).bold()
                        Text(master.artists?[0].name ?? "")
                            .foregroundStyle(.secondary)
                    }
                    .listRowSeparator(.hidden)
                    .padding(.bottom, 0)
                    Section("Informações do disco") {
                        MasterInfoRow(title: "Título", value: master.title)
                        MasterInfoRow(title: "Artista", value: master.artists?[0].name)
                        MasterInfoRow(title: "Lançamento", value: String(master.year ?? 0))
                        MasterInfoRow(title: "Gêneros", value: master.genres?.joined(separator: ", "))
                        MasterInfoRow(title: "Estilos", value: master.styles?.joined(separator: ", "))
                    }
                }.onAppear {tempMaster = master}
            }
        }
        .listStyle(.plain)
        
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    selectedMaster = tempMaster
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        
        .fullScreenCover(item: $selectedMaster) { master in
            VersionSelectView(master: master, selectedMaster: $selectedMaster)
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
