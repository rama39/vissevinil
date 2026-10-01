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
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(evento.tipo.rawValue)
                    .font(.headline)
                Spacer()
            }
            if let comment = evento.comentario {
                Text(comment)
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
