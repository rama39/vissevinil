//
//  AdicionandoDiscoView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 17/09/26.
//

import SwiftUI

struct VersionSelectView: View {
    @State private var versionViewModel = VersionViewModel()
    @State var master: MasterResponse
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
                        ProgressView("Carregando disco...")
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
                else if searchedVersions.isEmpty {
                    HStack {
                        Spacer()
                        Text("Nenhuma versão encontrada")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                } else {
                    ForEach(searchedVersions) { version in
                        VersionRow(version: version)
                    }
                    .searchable(text: $localSearch)
                }
            }
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
}
