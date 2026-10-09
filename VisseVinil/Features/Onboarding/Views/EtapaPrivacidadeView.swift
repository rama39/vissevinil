//
//  EtapaPrivacidadeView.swift
//  VisseVinil
//

import SwiftUI

/// Etapa 0 do onboarding (obrigatória): Política de Privacidade.
/// Como os termos nos apps da Apple: ícone de privacidade, título curto, a política inteira
/// em texto nativo num quadro com rolagem e, no pé do quadro, "Li e aceito". Embaixo, o link
/// do suporte (onde também está o PDF) e o botão principal, que só libera depois do aceite.
struct EtapaPrivacidadeView: View {
    let continuar: () -> Void

    @State private var aceito = false

    static let paginaDeSuporte = URL(string: "https://rama39.github.io/vissevinil/")!

    var body: some View {
        VStack(spacing: 20) {
            cabecalho

            quadro

            Text("Dúvidas? Acesse a nossa [página de suporte](\(Self.paginaDeSuporte.absoluteString)).")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
        .padding(.top, 24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom) {
            Button(action: continuar) {
                Text("Continuar")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(!aceito)
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)
        }
    }

    private var cabecalho: some View {
        VStack(spacing: 12) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 48))
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            Text("Sua Privacidade")
                .font(.largeTitle.bold())
                .accessibilityAddTraits(.isHeader)

            Text("Antes de começar, leia como o VisseVinil usa e protege os seus dados.")
                .foregroundStyle(.secondary)
        }
        .multilineTextAlignment(.center)
    }

    // A política rolando dentro do quadro e o aceite no pé dele
    private var quadro: some View {
        VStack(spacing: 0) {
            TextoDaPolitica()
                .frame(maxHeight: .infinity)

            Divider()

            Button {
                withAnimation(.snappy) { aceito.toggle() }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: aceito ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(aceito ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                        .contentTransition(.symbolEffect(.replace))
                    Text("Li e aceito a Política de Privacidade")
                        .foregroundStyle(.primary)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 16)
                .frame(minHeight: 52)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .sensoryFeedback(.selection, trigger: aceito)
            .accessibilityAddTraits(.isToggle)
            .accessibilityValue(aceito ? "Aceito" : "Não aceito")
        }
        .background(Color(.secondarySystemGroupedBackground),
                    in: RoundedRectangle(cornerRadius: 26, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}

/// A Política de Privacidade em texto nativo, com rolagem: títulos em negrito, parágrafos e
/// listas com marcador, como os termos dos apps da Apple.
private struct TextoDaPolitica: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(PoliticaDePrivacidade.titulo)
                        .font(.title2.bold())
                        .accessibilityAddTraits(.isHeader)
                    Text("Última atualização: \(PoliticaDePrivacidade.ultimaAtualizacao)")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }

                Text(PoliticaDePrivacidade.introducao)

                ForEach(PoliticaDePrivacidade.secoes) { secao in
                    Text(secao.titulo)
                        .font(.headline)
                        .padding(.top, 8)
                        .accessibilityAddTraits(.isHeader)

                    ForEach(secao.blocos, id: \.self) { bloco in
                        bloco.view
                    }
                }
            }
            .font(.subheadline)
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private extension PoliticaDePrivacidade.Bloco {
    @ViewBuilder
    var view: some View {
        switch self {
        case .paragrafo(let texto):
            Text(LocalizedStringKey(texto))
        case .subtitulo(let texto):
            Text(texto)
                .font(.subheadline.bold())
                .padding(.top, 4)
                .accessibilityAddTraits(.isHeader)
        case .lista(let itens):
            VStack(alignment: .leading, spacing: 6) {
                ForEach(itens, id: \.self) { item in
                    HStack(alignment: .firstTextBaseline, spacing: 8) {
                        Text("•")
                            .accessibilityHidden(true)
                        Text(LocalizedStringKey(item))
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        EtapaPrivacidadeView { }
    }
}
