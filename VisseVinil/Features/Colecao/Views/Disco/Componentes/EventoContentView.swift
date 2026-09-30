//
//  EventoContentView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 30/09/26.
//

import SwiftUI

struct EventoContentView: View {
    
    let evento: EventoModel
    
    var body: some View {
        switch evento.tipo {
        case .adicionou:
            Text("Adicionou o disco à coleção")
        case .tirouParaOuvir:
            //Image(systemName: "tray.and.arrow.up")
            Text("adicionou")
            Spacer()
        case .comentou:
            //HStack {
                //Image(systemName: "bubble")
            Text(evento.comentario ?? "Comentário vazio")
                //Spacer()
            //}
        }
    }
}
