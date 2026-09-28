//
//  DiscoView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 19/09/26.
//

import SwiftUI

struct BotaoDisco: View {
    let action: () -> Void
    let image: String
    let fill: Bool
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: image + (fill ? ".fill" : ""))
                .resizable().scaledToFit()
                .frame(width:25, height: 25)
        }
        .buttonStyle(.plain)
    }
}

struct DiscoView: View {
    
    @Bindable var disco: DiscoModel
    
    @State var removendoDaCaixa = false
    
    var body: some View {
        List {
            VStack(alignment: .leading, spacing: 0) {
                guessThumb(disco.thumbData)
                    .padding(.bottom)
                
                HStack {
                    if let caixa = disco.caixa {
                        // TODO: navigationdestination
                        //NavigationLink {
                        //    CaixaView(caixa: caixa)
                        //} label: {
                            CaixaTag(caixa: caixa)
                        //} .buttonStyle(.plain)
                    }
                    Spacer()
                    BotaoDisco(
                        action: {disco.curtido.toggle()},
                        image: "heart", fill: disco.curtido
                    )
                    .padding(.trailing)
                    BotaoDisco(
                        action: {disco.wishlist.toggle()},
                        image: "bookmark", fill: disco.wishlist
                    )
                }
                .padding(.bottom)
                
                Text(disco.title)
                    .font(.title2).bold()
                Text(disco.artistsListed)
                    .foregroundStyle(.secondary)
                
                if disco.caixa != nil {
                    RemoveDiscoButton(action: { removendoDaCaixa = true })
                }
            }
            .listRowSeparator(.hidden)
            .padding(.bottom, 0)
            
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
            // TODO: navigationdestination
            NavigationLink {
                ColecaoView()
                    .onAppear {
                        disco.removed = true
                    }
                    .navigationBarBackButtonHidden(true)
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
