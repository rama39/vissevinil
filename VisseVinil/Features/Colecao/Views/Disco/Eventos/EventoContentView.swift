//
//  EventoContentView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 30/09/26.
//

import SwiftUI


struct EventoContentView: View {
    
    let evento: EventoModel
    @Binding var existingComment: EventoModel?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(evento.tipo.rawValue)
                    .font(.headline)
                Spacer()
                if evento.tipo == .comentou {
                    Menu {
                        MenuLabel("Editar", .confirm, image: "pencil", action: {
                            existingComment = evento
                        })
                        MenuLabel("Excluir", .destructive, image: "trash", evento: evento)
                    } label: {
                        Image(systemName: "ellipsis")
                            .tint(.primary)
                            .frame(width: 25, height: 25)
                    }
                }
            }
            if let comment = evento.comentario {
                Text(comment)
                    .padding(.vertical, 5)
            }
            Text(evento.data.formatted(date: .abbreviated, time: .shortened))
                .foregroundStyle(.secondary)
                .font(.subheadline)
        }
        .padding()
        .background {Color(uiColor: UIColor.tertiaryLabel)}
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .padding(.horizontal)
    }
}
