//
//  AdicionandoDiscoView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 17/09/26.
//

import SwiftUI
import SwiftData

struct VersionSelectView: View {
    @Environment(\.modelContext) private var modelContext
    func save() { if modelContext.hasChanges { try? modelContext.save() } }
    @Query private var discos: [_DiscoModel]
    
    @State private var versionViewModel = VersionViewModel()
    let master: MasterResponse
    @Binding var selectedMaster: MasterResponse?
    
    @State var localSearch = ""
    var searchedVersions: [MasterVersion] {
        
        guard let masterversion = versionViewModel.masterversion,
              let versions = masterversion.versions
        else { return [] }
        
        return versions.filter({ version in
            
            let searchName = [
                master.artists?.map{$0.name ?? ""}.joined(separator: ", ") ?? "",
                master.title ?? "", version.country ?? "", version.released ?? ""
            ].joined(separator: " ")
            
            return localSearch.isEmpty ||
                   searchName.localizedCaseInsensitiveContains(localSearch)
            
        })
    }
    
    var body: some View {
        NavigationStack {
            List {
                if versionViewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView("Carregando versões...")
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                } else if versionViewModel.masterversion == nil {
                    HStack {
                        Spacer()
                        Text("Erro carregando vinil.")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                }
                else {
                    Group {
                        if searchedVersions.isEmpty {
                            HStack {
                                Spacer()
                                Text("Nenhuma versão encontrada")
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                            .listRowSeparator(.hidden)
                        } else {
                            ForEach(searchedVersions) { version in
                                let savedIndex = discos.first(
                                    where: { $0.id == version.id }
                                )
                                VersionRow(master: master, version: version, action: {
                                    if let savedIndex {
                                        deleteDisco(savedIndex)
                                    } else {
                                        saveDisco(version: version)
                                    }
                                }, saved: savedIndex != nil)
                            }
                        }
                    }
                    .searchable(text: $localSearch)
                }
            }
            .navigationTitle("Versões")
            .navigationBarTitleDisplayMode(.automatic)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { selectedMaster = nil } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .onAppear {
            Task {
                await versionViewModel.requestVersions(id: master.id ?? 0)
            }
        }
    }
    
    
    private func getDiscoModel(version: MasterVersion) -> _DiscoModel {
//        _DiscoModel(
//            title: version.title ?? "",
//            artists: master.artists?.map{$0.name ?? ""} ?? [],
//            year: version.released ?? "",
//            country: version.country ?? "",
//            genres: master.genres ?? [],
//            styles: master.styles ?? [],
//            thumbData: version.thumbData,
//            id: version.id,
//            posicao: discos.count
//        )
        _DiscoModel(master: master, version: version, posicao: discos.count)
    }
    
    private func saveDisco(version: MasterVersion) {
        withAnimation {
            let newDisco = getDiscoModel(version: version)
            print("\(master)")
            modelContext.insert(newDisco)
            let newEvento = EventoModel(.adicionou)
            newEvento.disco = newDisco
            modelContext.insert(newEvento)
            save()
        }
    }

    private func deleteDisco(_ saved: _DiscoModel) {
        withAnimation {
            let deletedDisco = saved
            let pos = deletedDisco.posicao
            for i in discos.indices {
                if discos[i].posicao > pos {
                    discos[i].posicao -= 1
                }
            }
            modelContext.delete(deletedDisco)
            save()
        }
    }
}
