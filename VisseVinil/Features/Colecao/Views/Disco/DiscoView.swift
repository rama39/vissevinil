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
    @State var adicionandoComentario = false
    
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
            
            Section("Minhas impressões") {
                HStack {
                    Text("Avaliação")
                    Spacer()
                    ForEach(1...5, id: \.self) { i in
                        BotaoStar(stars: $disco.estrelas, i: i)
                    }
                }
                let estadosCapa = Array(descricaoEstados.keys).sorted(by: {$0.rawValue < $1.rawValue})
                let estadosDisco = estadosCapa.dropFirst(2).compactMap { EstadoDisco(rawValue: $0.rawValue) }
                Picker("Estado da Capa", selection: $disco.estadoCapa) {
                    Text(disco.estadoCapa != nil ?
                         "Remover Estado" : "Selecionar").tag(nil as EstadoCapa?)
                    
                    Divider()
                    
                    ForEach(estadosCapa, id: \.self) { estado in
                        Text(titleEstados[estado] ?? "").tag(estado)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                Picker("Estado do Disco", selection: $disco.estadoDisco) {
                    Text(disco.estadoDisco != nil ?
                         "Remover Estado" : "Selecionar").tag(nil as EstadoDisco?)
                    
                    Divider()
                    
                    ForEach(estadosDisco, id: \.self) { estado in
                        Text(EstadoCapa(rawValue: estado.rawValue).flatMap { titleEstados[$0] } ?? "").tag(estado)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                VStack(alignment: .leading) {
                    HStack {
                        Text("Eventos")
                        Spacer()
                        Button {
                            adicionandoComentario = true
                        } label: {
                            HStack {
                                Image(systemName: "square.and.pencil")
                                Text("Comentário")
                            }
                            .padding(15)
                            .glassEffect()
                        }.buttonStyle(.plain)
                    }
                    VStack(alignment: .leading, spacing: 0) {
                        let last = disco.eventos.last
                        ForEach(disco.eventos) { evento in
                            EventoView(evento: evento, notLast: (evento != last))
                        }
                    }
                }
            }.padding(.bottom)
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
                        disco.whenRemoved = Date()
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
        
        .sheet(isPresented: $adicionandoComentario, content: {ComentarioSheet(disco: disco)})
    }
}
