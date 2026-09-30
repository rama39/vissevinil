//
//  EventoView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 30/09/26.
//

import SwiftUI

struct EventoView: View {
    
    let evento: EventoModel
    let notLast: Bool
    
    var body: some View {
        let elementColor = Color(uiColor: UIColor.tertiaryLabel)
        HStack(alignment: .top, spacing: 0) {
            VStack(spacing: 0) {
                Circle()
                    .fill(elementColor)
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: (imageEvento[evento.tipo] ?? ""))
                            .resizable().scaledToFit()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.primary)
                    }
                if notLast {
                    Rectangle()
                        .fill(elementColor)
                        .frame(width: 3)
                }
            }
            EventoContentView(evento: evento)
        }
    }
}
