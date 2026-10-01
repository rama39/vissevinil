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
    
    let iconSize = 50.0
    let lineWidth = 3.0
    
    var body: some View {
        let elementColor = Color(uiColor: UIColor.tertiaryLabel)
        HStack(alignment: .top, spacing: 0) {
            EventoIcon(elementColor: elementColor, systemImage: imageEvento[evento.tipo] ?? "", iconSize: iconSize)
            EventoContentView(evento: evento)
        }
        .padding(.bottom)
        
        .background(alignment: .topLeading) {
            if notLast {
                Rectangle()
                    .fill(elementColor)
                    .frame(width: lineWidth)
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding(.top, iconSize)
                    .padding(.leading, (iconSize - lineWidth) / 2)
            }
        }
        
        
//            .contextMenu {
//                Button {  }
//                label: { Label("Editar", systemImage: "square.and.pencil") }
//            }
//            .buttonStyle(.plain)
    }
}
