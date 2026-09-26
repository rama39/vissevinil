//
//  EditarContatoView.swift
//  VisseVinil
//

import SwiftUI
import SwiftData

/// Edita telefone e site do local (o endereço vem do mapa e não é editável).
/// Campo vazio = volta a usar o que o Apple Maps informar.
struct EditarContatoView: View {
    let chaveDoLocal: String
    let nomeDoLocal: String

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var contatos: [ContatoDoLocal]
    @State private var telefone: String
    @State private var site: String

    init(chaveDoLocal: String, nomeDoLocal: String, telefone: String, site: String) {
        self.chaveDoLocal = chaveDoLocal
        self.nomeDoLocal = nomeDoLocal
        _telefone = State(initialValue: telefone)
        _site = State(initialValue: site)
        let chave = chaveDoLocal
        _contatos = Query(filter: #Predicate<ContatoDoLocal> { $0.chaveDoLocal == chave })
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Telefone", text: $telefone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                } header: {
                    Text("Telefone")
                }

                Section {
                    TextField("exemplo.com.br", text: $site)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                } header: {
                    Text("Site")
                } footer: {
                    Text("Use quando o local não tiver essas informações no mapa. O endereço não pode ser editado.")
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
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    private func salvar() {
        let telefoneLimpo = telefone.trimmingCharacters(in: .whitespacesAndNewlines)
        let siteLimpo = site.trimmingCharacters(in: .whitespacesAndNewlines)

        if let contato = contatos.first {
            contato.telefone = telefoneLimpo
            contato.site = siteLimpo
        } else {
            modelContext.insert(ContatoDoLocal(chaveDoLocal: chaveDoLocal,
                                               telefone: telefoneLimpo, site: siteLimpo))
        }
        dismiss()
    }
}
