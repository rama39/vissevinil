//
//  MenuLabel.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 02/10/26.
//

import SwiftUI
import SwiftData

struct MenuLabel: View {
    @Environment(\.modelContext) private var modelContext
    func save() { if modelContext.hasChanges { try? modelContext.save() } }
    @Query private var eventos: [EventoModel]
    
    let titulo: String
    let role: ButtonRole
    let image: String
    let action: () -> Void
    
    let evento: EventoModel?
    
    init(_ titulo: String, _ role: ButtonRole, image: String, action: @escaping () -> Void = {}, evento: EventoModel? = nil) {
        self.titulo = titulo
        self.role = role
        self.image = image
        self.action = action
        self.evento = evento
    }
    
    var body: some View {
        Button(role: role) {
            withAnimation {
                if role == .destructive,
                   let evento {
                    let deletedEvento = evento
                    modelContext.delete(deletedEvento)
                    save()
                } else {
                    action()
                }
            }
        } label: {
            Label(titulo, systemImage: image)
        }
    }
}
