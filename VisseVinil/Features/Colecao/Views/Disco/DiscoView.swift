//
//  DiscoView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 19/09/26.
//

import SwiftUI

struct DiscoView: View {
    
    @Bindable var disco: _DiscoModel
    
    var body: some View {
        List {
            guessThumb(disco.thumbData)
                .resizable().scaledToFit().padding()
                .listRowSeparator(.hidden)
            Text(disco.title)
                .listRowSeparator(.hidden)
            Text(disco.artistsListed)
            
            Section("Informações do disco") {
                MasterInfoRow(title: "Título", value: disco.title)
                MasterInfoRow(title: "Artista", value: disco.artistsListed)
                MasterInfoRow(title: "Lançamento", value: disco.released)
                MasterInfoRow(title: "Gêneros", value: disco.genresListed)
                MasterInfoRow(title: "Subgêneros", value: disco.stylesListed)
            }
        }
        .listStyle(.plain)
        .navigationTitle(disco.title)
        .navigationBarTitleDisplayMode(.automatic)
    }
}
