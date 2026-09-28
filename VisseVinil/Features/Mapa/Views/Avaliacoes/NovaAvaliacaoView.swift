//
//  NovaAvaliacaoView.swift
//  VisseVinil
//

import SwiftUI
import SwiftData

/// Nova avaliação pessoal: nota opcional + comentário. Dia e hora são salvos automaticamente.
struct NovaAvaliacaoView: View {
    let chaveDoLocal: String
    let nomeDoLocal: String

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var nota = 0
    @State private var comentario = ""

    private var comentarioLimpo: String {
        comentario.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var podeSalvar: Bool {
        nota > 0 || !comentarioLimpo.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Nota") {
                    SeletorDeEstrelas(nota: $nota)
                        .padding(.vertical, 6)
                }

                Section {
                    TextField("Como foi a visita? O que você achou do acervo?", text: $comentario, axis: .vertical)
                        .lineLimit(4...10)
                } header: {
                    Text("Comentário")
                } footer: {
                    Text("Só você vê suas avaliações. A data e a hora são salvas automaticamente.")
                }
            }
            .scrollEdgeEffectStyle(.soft, for: .all)
            .navigationTitle(nomeDoLocal)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm, action: salvar)
                        .disabled(!podeSalvar)
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func salvar() {
        modelContext.insert(AvaliacaoDoLocal(
            chaveDoLocal: chaveDoLocal,
            nota: nota,
            comentario: comentarioLimpo.isEmpty ? nil : comentarioLimpo
        ))
        dismiss()
    }
}
