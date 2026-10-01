//
//  MasterDetailView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 11/09/26.
//

import SwiftUI
import SwiftData

struct MasterView: View {
    @Environment(\.modelContext) private var modelContext
    func save() { if modelContext.hasChanges { try? modelContext.save() } }
    @Query private var curtidas: [CurtidaModel]
    @Query private var desejados: [WishlistModel]
    
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
                            Spacer()
                            let curtida = curtidas.first(where: {$0.master_id == master.id})
                            BotaoDisco( action: {
                                if curtida == nil {
                                    saveCurtida(master: master)
                                } else {
                                    deleteCurtida(curtida: curtida!)
                                }
                            }, image: "heart", fill: curtida != nil)
                            .padding(.trailing)
                            
//                            let desejado = desejados.first(where: {$0.master_id == master.id})
//                            BotaoDisco( action: {
//                                if curtida == nil {
//                                    saveCurtida(master: master)
//                                } else {
//                                    deleteCurtida(curtida: curtida!)
//                                }
//                            }, image: "bookmark", fill: curtida != nil)
                        }
                        .padding(.bottom)
                        Text(master.title ?? "")
                            .font(.title2).bold()
                        Text(master.artists?.first?.name ?? "")
                            .foregroundStyle(.secondary)
                    }
                    .listRowSeparator(.hidden)
                    .padding(.bottom, 0)
                    Section("Informações do disco") {
                        MasterInfoRow(title: "Título", value: master.title)
                        MasterInfoRow(title: "Artista", value: master.artists?.first?.name)
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
    
    func saveCurtida(master: MasterResponse) {
        withAnimation {
            let newCurtida = CurtidaModel(master: master)
            modelContext.insert(newCurtida)
            save()
        }
    }

    func deleteCurtida(curtida: CurtidaModel) {
        withAnimation {
            let deletedCurtida = curtida
            modelContext.delete(deletedCurtida)
            save()
        }
    }
}


#Preview {
    NavigationStack {
        MasterView(master_id: 1000)
    }
}
