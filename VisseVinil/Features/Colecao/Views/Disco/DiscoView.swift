//
//  DiscoView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 19/09/26.
//

import SwiftUI

struct DiscoView: View {
    
    @Bindable var disco: DiscoModel
    
    @State var removendoDaCaixa = false
    
    var body: some View {
        List {
            guessThumb(disco.thumbData)
                .resizable().scaledToFit().padding()
                .listRowSeparator(.hidden)
            if disco.caixa != nil {
                Button() {
                    withAnimation {
                        removendoDaCaixa = true
                    }
                } label: {
                    ZStack {
                        Color.green.opacity(0.25)
                        HStack {
                            Image(systemName: "tray.and.arrow.up")
                            Spacer()
                            Text("Pegar Disco")
                            Spacer()
                        }.padding()
                    }.foregroundStyle(.green)
                }.listRowSeparator(.hidden)
                    .clipShape(RoundedRectangle(cornerRadius: 100))
            }
            HStack {
                if let caixa = disco.caixa {
                    Text(caixa.title)
                }
                Spacer()
                Button {
                    disco.curtido.toggle()
                } label: {
                    Image(systemName: "heart" + (disco.curtido ? ".fill" : ""))
                }
            }
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
        
        .alert("Você tem certeza?", isPresented: $removendoDaCaixa) {
            // TODO: MAKE BLUE
            NavigationLink {
                ColecaoView()
                    .onAppear {
                        disco.removed = true
                    }
            } label: {
                Text("Confirmar")
            }
            Button("Cancelar", role: .cancel) {
                removendoDaCaixa = false
            }
        } message: {
            if disco.caixa != nil {
                Text("Ao confirmar, o disco será removido da caixa.")
            }
        }
    }
}
