//
//  TodasAvaliacoesView.swift
//  VisseVinil
//

import SwiftUI
import SwiftData

/// Todas as avaliações pessoais de um local, da mais recente pra mais antiga.
/// Deslize pra apagar; "+" pra adicionar uma nova.
struct TodasAvaliacoesView: View {
    let chaveDoLocal: String
    let nomeDoLocal: String

    @Environment(\.modelContext) private var modelContext
    @Query private var avaliacoes: [AvaliacaoDoLocal]
    @State private var escrevendo = false

    init(chaveDoLocal: String, nomeDoLocal: String) {
        self.chaveDoLocal = chaveDoLocal
        self.nomeDoLocal = nomeDoLocal
        let chave = chaveDoLocal
        _avaliacoes = Query(
            filter: #Predicate<AvaliacaoDoLocal> { $0.chaveDoLocal == chave },
            sort: \.data,
            order: .reverse
        )
    }

    private var notas: [Int] {
        avaliacoes.map(\.nota).filter { $0 > 0 }
    }

    var body: some View {
        List {
            if !notas.isEmpty {
                let media = Double(notas.reduce(0, +)) / Double(notas.count)
                Section {
                    HStack(spacing: 12) {
                        Text(media.formatted(.number.precision(.fractionLength(1))))
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        VStack(alignment: .leading, spacing: 4) {
                            EstrelasDeNota(nota: media)
                            Text(notas.count == 1 ? "Sua nota" : "Sua média em \(notas.count) visitas")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .accessibilityElement(children: .combine)
                }
            }

            Section {
                ForEach(avaliacoes) { avaliacao in
                    CartaoDeAvaliacao(avaliacao: avaliacao, comFundo: false)
                }
                .onDelete { indices in
                    for indice in indices {
                        modelContext.delete(avaliacoes[indice])
                    }
                }
            }
        }
        .overlay {
            if avaliacoes.isEmpty {
                ContentUnavailableView(
                    "Nenhuma avaliação",
                    systemImage: "star.bubble",
                    description: Text("Dê uma nota e anote como foi cada visita. Só você vê.")
                )
            }
        }
        .scrollEdgeEffectStyle(.soft, for: .all)
        .navigationTitle("Suas Avaliações")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Avaliar", systemImage: "plus") {
                    escrevendo = true
                }
            }
        }
        .sheet(isPresented: $escrevendo) {
            NovaAvaliacaoView(chaveDoLocal: chaveDoLocal, nomeDoLocal: nomeDoLocal)
        }
    }
}
