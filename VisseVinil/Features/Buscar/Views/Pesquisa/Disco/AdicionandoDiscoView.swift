//
//  AdicionandoDiscoView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 17/09/26.
//

import SwiftUI

struct AdicionandoDiscoView: View {
    @State private var releaseViewModel = DiscogsMasterVersionViewModel()
    @Binding var discoAdicionado: DiscogsMasterResponse?
    @State var master: DiscogsMasterResponse
    var body: some View {
        NavigationStack {
            List {
                if releaseViewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView("Carregando disco...")
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                } else if releaseViewModel.masterversion == nil {
                    HStack {
                        Spacer()
                        Text("Erro carregando vinil.")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                }
                else if let masterversion = releaseViewModel.masterversion,
                        let versions = masterversion.versions{
                    ForEach(versions) { version in
                        AdicionadoDiscoOuterView(version: version)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { discoAdicionado = nil } label: {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
        .onAppear {
            Task {
                await releaseViewModel.requestVinyl(id: master.id ?? 0)
            }
        }
    }
}
