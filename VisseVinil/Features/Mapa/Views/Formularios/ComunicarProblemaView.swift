//
//  ComunicarProblemaView.swift
//  VisseVinil
//

import SwiftUI
import SwiftData

/// Comunicar um problema com o local. Fica salvo no aparelho e será repassado pra equipe
/// quando houver um canal de envio (ex: CloudKit); por enquanto ninguém recebe.
struct ComunicarProblemaView: View {
    let chaveDoLocal: String
    let nomeDoLocal: String

    private static let tipos = [
        "Endereço incorreto",
        "Localização errada no mapa",
        "Telefone ou site incorretos",
        "Horário ou informações desatualizadas",
        "Local fechado permanentemente",
        "Outro problema",
    ]

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var tipo = tipos[0]
    @State private var descricao = ""
    @State private var enviado = false

    var body: some View {
        NavigationStack {
            Form {
                Section("O que está errado?") {
                    Picker("Problema", selection: $tipo) {
                        ForEach(Self.tipos, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }

                Section {
                    TextField("Conte mais detalhes (opcional)", text: $descricao, axis: .vertical)
                        .lineLimit(3...8)
                } header: {
                    Text("Detalhes")
                } footer: {
                    Text("Seu relato sobre \(nomeDoLocal) fica salvo e será repassado para a equipe do VisseVinil.")
                }
            }
            .scrollEdgeEffectStyle(.soft, for: .all)
            .navigationTitle("Comunicar Problema")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .close) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm, action: enviar)
                        .accessibilityLabel("Enviar")
                }
            }
            .alert("Obrigado!", isPresented: $enviado) {
                Button("OK") { dismiss() }
            } message: {
                Text("Sua mensagem foi salva e será repassada para a equipe assim que possível.")
            }
        }
        .presentationDetents([.large])
    }

    private func enviar() {
        modelContext.insert(ProblemaReportado(
            chaveDoLocal: chaveDoLocal,
            nomeDoLocal: nomeDoLocal,
            tipo: tipo,
            descricao: descricao.trimmingCharacters(in: .whitespacesAndNewlines)
        ))
        enviado = true
    }
}
