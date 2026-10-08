//
//  DiscoView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 19/09/26.
//

import SwiftUI

struct DiscoView: View {
    //@Environment(\.dismiss) var dismiss
    
    @Bindable var disco: DiscoModel
    
    @State var removendoDaCaixa = false
    @State var RemoveuDisco = false
    @State var adicionandoComentario = false
    @State var existingComment: EventoModel? = nil
    
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
                    BotaoCurtidaDisco(disco: disco)
                    //.padding(.trailing)
//                    BotaoDisco(
//                        action: {disco.wishlist.toggle()},
//                        image: "bookmark", fill: disco.wishlist
//                    )
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
                PickerEstado<EstadoCapa>(
                    "Estado da Capa", $disco.estadoCapa,
                    estados: estadosCapa
                )
                PickerEstado<EstadoDisco>(
                    "Estado do Disco", $disco.estadoDisco,
                    estados: estadosDisco
                )
                EventoListView(
                    adicionandoComentario: $adicionandoComentario,
                    eventos: disco.eventos,
                    existingComment: $existingComment
                )
                .onChange(of: existingComment) {
                    if existingComment != nil { adicionandoComentario = true }
                }
            }.padding(.bottom)
        }
        .listStyle(.plain)
        .navigationTitle(disco.title)
        .navigationBarTitleDisplayMode(.automatic)
        
        .alert("Você tem certeza?", isPresented: $removendoDaCaixa) {
            Button("Cancelar", role: .cancel) {
                removendoDaCaixa = false
            }
            Button("Confirmar") {
                disco.removed = true
                disco.whenRemoved = Date()
                RemoveuDisco = true
                // TODO: investigate dismiss across versions
                //dismiss()
            }
            // forma gambiarrosa de deixar proeminente
            .keyboardShortcut(.defaultAction)
        } message: {
            if disco.caixa != nil {
                Text("Ao confirmar, o disco será removido da caixa.")
            }
        }
        
        .navigationDestination(isPresented: $RemoveuDisco) {
            ColecaoView()
                .navigationBarBackButtonHidden(true)
        }
        
        .sheet(isPresented: $adicionandoComentario, content: {ComentarioSheet(disco: disco, existingComment: $existingComment)})
    }
}
