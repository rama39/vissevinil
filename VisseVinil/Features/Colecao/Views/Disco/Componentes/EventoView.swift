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
        let elementColor = Color.primary
        HStack(spacing: 0) {
            VStack(spacing: 0) {
                Circle()
                    .fill(elementColor)
                    .frame(width: 25, height: 25)
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
