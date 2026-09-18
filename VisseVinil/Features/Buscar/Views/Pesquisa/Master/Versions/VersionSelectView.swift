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
                else if let masterversion = versionViewModel.masterversion,
                        let versions = masterversion.versions{
                    ForEach(versions) { version in
                        VersionRow(version: version)
                    }
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
