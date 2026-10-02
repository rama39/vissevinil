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
    
    @State var newComentarioText: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                TextField("Digite seu comentário aqui...", text: $newComentarioText, axis: .vertical)
                    .lineLimit(20...)
                    .font(.body)
                    .padding()
                    .onSubmit {
                        saveComment()
                    }
                
                    //.background()
                    //.clipShape(RoundedRectangle(cornerRadius: 25))
            }
                .navigationTitle("Novo Comentário")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(role: .confirm) {
                            saveComment()
                        }
                    }
                }
        }
    }
    
    func saveComment() {
        withAnimation {
            
            dismiss()
            
            guard !newComentarioText.isEmpty else { return }
            
            let newEvento = EventoModel(.comentou, newComentarioText)
            newEvento.disco = disco
            modelContext.insert(newEvento)
            save()
        }
    }
}
