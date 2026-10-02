//
//  ComentarioSheet.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 28/09/26.
//

import SwiftUI
import SwiftData

struct ComentarioSheet: View {
    @Environment(\.modelContext) private var modelContext
    func save() { if modelContext.hasChanges { try? modelContext.save() } }
    @Query private var eventos: [EventoModel]
    
    @Environment(\.dismiss) private var dismiss
    
    let disco: DiscoModel
    @Binding var existingComment: EventoModel?
    
    @State var newComentarioText: String = ""
    
    init(disco: DiscoModel, existingComment: Binding<EventoModel?>) {
        self.disco = disco
        self._existingComment = existingComment
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                TextField("Digite seu comentário aqui...", text: $newComentarioText, axis: .vertical)
                    .lineLimit(20...)
                    .font(.body)
                    .padding()
            }
            .navigationTitle(
                existingComment == nil ?
                "Novo Comentário" : "Editar Comentário"
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(role: .confirm) {
                        saveComment()
                    }
                }
            }
            .onAppear {
                if let existingComment,
                   let comentario = existingComment.comentario{
                    newComentarioText = comentario
                }
            }
        }
    }
    
    func saveComment() {
        withAnimation {
            
            dismiss()
            guard !newComentarioText.isEmpty else { return }
            
            if let existingComment {
                existingComment.comentario = newComentarioText
            } else {
                let newEvento = EventoModel(.comentou, newComentarioText)
                newEvento.disco = disco
                modelContext.insert(newEvento)
            }
            existingComment = nil
            save()
        }
    }
}
