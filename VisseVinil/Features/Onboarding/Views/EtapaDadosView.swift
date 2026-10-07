//
//  EtapaDadosView.swift
//  VisseVinil
//

import SwiftUI

/// Etapa 1 do onboarding (obrigatória): nome de usuário e desde quando coleciona.
/// Só componentes do sistema, como nas telas de configuração da Apple: título no topo,
/// lista agrupada com uma seção (e legenda) pra cada dado e botão principal embaixo.
struct EtapaDadosView: View {
    @Binding var nome: String
    @Binding var colecionaDesde: Date
    let continuar: () -> Void

    private var nomeValido: Bool {
        !nome.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        Form {
            Section {
                VStack(spacing: 12) {
                    Image(systemName: "person.crop.circle")
                        .font(.system(size: 56, weight: .light))
                        .foregroundStyle(.tint)
                        .accessibilityHidden(true)

                    Text("Crie Seu Perfil")
                        .font(.largeTitle.bold())
                        .accessibilityAddTraits(.isHeader)

                    Text("Seu nome e desde quando você coleciona aparecem no seu perfil.")
                        .foregroundStyle(.secondary)
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())

            Section("Nome de Usuário") {
                TextField("Como quer ser chamado", text: $nome)
                    .textContentType(.nickname)
                    .autocorrectionDisabled()
                    .submitLabel(.done)
            }

            Section {
                DatePicker("Início da Coleção", selection: $colecionaDesde,
                           in: ...Date.now, displayedComponents: .date)
            } header: {
                Text("Coleciona Desde")
            } footer: {
                Text("Começa com a data de hoje. Se você já coleciona há mais tempo, escolha quando começou.")
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) {
            Button(action: continuar) {
                Text("Continuar")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!nomeValido)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }
}
