//
//  EscolherFavoritosView.swift
//  VisseVinil
//

import SwiftUI
import SwiftData

/// Sheet pra escolher até 4 discos favoritos da coleção (aberta pela edição do perfil).
/// Trabalha numa cópia da seleção: "OK" devolve a escolha pra edição do perfil, o X descarta.
/// Nada é salvo aqui; quem grava é o ✓ da edição do perfil.
struct EscolherFavoritosView: View {
    static let limite = 4

    @Binding var escolhidos: [PersistentIdentifier]
    @Environment(\.dismiss) private var dismiss

    @Query private var discos: [DiscoModel]
    @State private var selecao: [PersistentIdentifier] = []
    @State private var pesquisa = ""

    // Só discos da coleção (sem a lista de desejos), em ordem alfabética
    private var discosPesquisados: [DiscoModel] {
        discos
            .filter { !$0.wishlist }
            .filter { pesquisa.isEmpty || $0.title.localizedCaseInsensitiveContains(pesquisa) }
            .sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
    }

    private var cheio: Bool { selecao.count >= Self.limite }

    var body: some View {
        NavigationStack {
            List(discosPesquisados) { disco in
                linha(disco)
            }
            .overlay {
                if discosPesquisados.isEmpty {
                    ContentUnavailableView.search(text: pesquisa)
                }
            }
            .navigationTitle("Discos Favoritos")
            // Quantos já foram escolhidos, sempre à vista
            .navigationSubtitle("\(selecao.count) de \(Self.limite) selecionados")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $pesquisa, placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Pesquisar Discos da Coleção")
            .contentMargins(.top, 8, for: .scrollContent)
            .sensoryFeedback(.selection, trigger: selecao)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(role: .confirm) {
                        escolhidos = selecao
                        dismiss()
                    }
                }
            }
        }
        .onAppear { selecao = escolhidos }
    }

    // Linha inteira tocável; com 4 escolhidos, os outros ficam apagados até liberar uma vaga
    private func linha(_ disco: DiscoModel) -> some View {
        let id = disco.persistentModelID
        let selecionado = selecao.contains(id)
        let bloqueado = cheio && !selecionado

        return Button {
            withAnimation(.snappy) {
                if selecionado {
                    selecao.removeAll { $0 == id }
                } else if !cheio {
                    selecao.append(id)
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: selecionado ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(selecionado ? AnyShapeStyle(.tint) : AnyShapeStyle(.tertiary))
                    // Círculo vira check preenchido com a animação do próprio símbolo
                    .contentTransition(.symbolEffect(.replace))
                    .symbolEffect(.bounce, value: selecionado)
                ColecaoPesquisaRow(disco: disco)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(bloqueado)
        .opacity(bloqueado ? 0.4 : 1)
        .accessibilityAddTraits(selecionado ? .isSelected : [])
        .accessibilityHint(bloqueado ? "Limite de \(Self.limite) favoritos atingido" : "")
    }
}
