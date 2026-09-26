//
//  BuscaVaziaView.swift
//  VisseVinil
//

import SwiftUI

/// Busca aberta sem texto: fixados e favoritos em rolagem lateral e recentes em lista, sobre
/// fundo desfocado.
struct BuscaVaziaView: View {
    let locaisSalvos: LocaisSalvosStore
    let selecionar: (Loja) -> Void

    @State private var confirmandoLimpeza = false

    var body: some View {
        List {
            if !locaisSalvos.fixados.isEmpty {
                Section {
                    CarrosselDeLocais(locais: locaisSalvos.fixados, estilo: locaisSalvos.estilo(para:),
                                      textoRemover: "Desafixar", iconeRemover: "pin.slash",
                                      remover: locaisSalvos.alternarFixado, selecionar: selecionar)
                } header: {
                    CabecalhoDaBusca("Fixados")
                }
                .headerProminence(.increased)
            }

            if !locaisSalvos.favoritos.isEmpty {
                Section {
                    CarrosselDeLocais(locais: locaisSalvos.favoritos, estilo: locaisSalvos.estilo(para:),
                                      textoRemover: "Remover dos Favoritos", iconeRemover: "star.slash",
                                      remover: locaisSalvos.alternarFavorito, selecionar: selecionar)
                } header: {
                    CabecalhoDaBusca("Favoritos")
                }
                .headerProminence(.increased)
            }

            if !locaisSalvos.recentes.isEmpty {
                Section {
                    ForEach(locaisSalvos.recentes) { recente in
                        LinhaDeLocal(titulo: Text(recente.nome), subtitulo: recente.endereco,
                                     estilo: estilo(doRecente: recente)) {
                            selecionar(LocaisSalvosStore.loja(de: recente))
                        }
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: locaisSalvos.removerRecentes)
                } header: {
                    HStack {
                        CabecalhoDaBusca("Recentes")
                        Spacer()
                        Button("Limpar") {
                            confirmandoLimpeza = true
                        }
                        .font(.subheadline)
                        .textCase(nil)
                    }
                }
                .headerProminence(.increased)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(.ultraThinMaterial)
        .scrollEdgeEffectStyle(.soft, for: .all)
        .scrollDismissesKeyboard(.immediately)
        .overlay {
            if locaisSalvos.estaVazio {
                ContentUnavailableView(
                    "Busque lojas e lugares",
                    systemImage: "magnifyingglass",
                    description: Text("Seus locais fixados, favoritos e buscas recentes aparecem aqui.")
                )
            }
        }
        // Alerta centralizado (a confirmationDialog abria como folha presa à barra)
        .alert("Limpar buscas recentes?", isPresented: $confirmandoLimpeza) {
            Button("Limpar", role: .destructive, action: locaisSalvos.limparRecentes)
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Essa ação não pode ser desfeita.")
        }
    }

    // Recente de loja cadastrada usa o ícone da loja; os demais, o relógio
    private func estilo(doRecente recente: LocalSalvo) -> EstiloDeLocal {
        CorrespondenciaDeLocais.ehLojaCadastrada(recente, em: locaisSalvos.lojasCadastradas)
            ? .lojaCadastrada
            : .recente
    }
}
