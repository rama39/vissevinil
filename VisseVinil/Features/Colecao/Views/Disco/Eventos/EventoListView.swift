//
//  EventoListView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 02/10/26.
//

import SwiftUI

struct EventoListView: View {
    @Binding var adicionandoComentario: Bool
    let eventos: [EventoModel]
    @Binding var existingComment: EventoModel?
    var body: some View {
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
                let last = eventos.last
                ForEach(eventos.sorted(by: {$0.data < $1.data})) { evento in
                    EventoView(evento: evento, existingComment: $existingComment, notLast: (evento != last))
                }
            }
        }
    }
}

