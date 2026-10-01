//
//  Ordenacao.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 26/09/26.
//

import Foundation

/// Onde a lista de discos está sendo ordenada. Muda o sentido de "Manual" e "Data de Inclusão".
enum ContextoDeOrdenacao {
    /// Todos os discos da coleção (manual = `posicao`, inclusão = quando entrou na coleção)
    case colecao
    /// Discos de uma caixa (manual = `posicaoCaixa`, inclusão = quando entrou na caixa)
    case caixa
}

/// Critério de ordenação dos discos, escolhido no menu "Ordenar Por" (como no app Notas).
enum Ordenacao: String, CaseIterable, Identifiable {
    /// Ordem definida pela pessoa, arrastando os discos
    case manual
    case titulo
    case artista
    case lancamento
    case inclusao

    var id: String { rawValue }

    func titulo(em contexto: ContextoDeOrdenacao) -> String {
        switch self {
        case .manual: "Manual"
        case .titulo: "Título"
        case .artista: "Artista"
        case .lancamento: "Data de Lançamento"
        case .inclusao: contexto == .caixa ? "Data de Inclusão na Caixa" : "Data de Inclusão"
        }
    }

    var icone: String {
        switch self {
        case .manual: "hand.draw"
        case .titulo: "textformat"
        case .artista: "music.mic"
        case .lancamento: "calendar"
        case .inclusao: "clock"
        }
    }

    /// Manual não tem direção (a ordem é a que a pessoa montou)
    var temDirecao: Bool { self != .manual }

    /// Direção natural de cada critério: A a Z nos textos, mais recentes primeiro nas datas
    var crescentePorPadrao: Bool {
        switch self {
        case .titulo, .artista: true
        case .manual, .lancamento, .inclusao: false
        }
    }

    /// Nome da direção, como no Notas ("A a Z" / "Mais Recentes Primeiro")
    func rotuloDaDirecao(crescente: Bool) -> String {
        switch self {
        case .titulo, .artista:
            crescente ? "A a Z" : "Z a A"
        case .manual, .lancamento, .inclusao:
            crescente ? "Mais Antigos Primeiro" : "Mais Recentes Primeiro"
        }
    }

    func iconeDaDirecao(crescente: Bool) -> String {
        crescente ? "arrow.up" : "arrow.down"
    }
}

// MARK: - Datas usadas na ordenação

extension DiscoModel {
    /// Quando o disco entrou na coleção (evento "Adicionou disco na coleção")
    var adicionadoNaColecaoEm: Date? {
        eventos.filter { $0.tipo == .adicionou }.map(\.data).min()
    }

    /// Ano/data de lançamento comparável ("2011" ou "2011-05-02"); nil quando não informado
    var lancamentoComparavel: String? {
        let limpo = released.trimmingCharacters(in: .whitespaces)
        return limpo.isEmpty ? nil : limpo
    }
}

// MARK: - Ordenar

extension Array where Element == DiscoModel {
    func ordenados(por ordenacao: Ordenacao, crescente: Bool, em contexto: ContextoDeOrdenacao) -> [DiscoModel] {
        switch ordenacao {
        case .manual:
            return ordemManual(em: contexto)

        case .titulo:
            return sorted { a, b in
                Self.compararTexto(a.title, b.title, crescente: crescente)
                    ?? Self.compararTexto(a.artistsListed, b.artistsListed, crescente: true)
                    ?? false
            }

        case .artista:
            return sorted { a, b in
                Self.compararTexto(a.artistsListed, b.artistsListed, crescente: crescente)
                    ?? Self.compararTexto(a.title, b.title, crescente: true)
                    ?? false
            }

        case .lancamento:
            return sorted { a, b in
                // Sem data de lançamento vai sempre pro fim, nas duas direções
                switch (a.lancamentoComparavel, b.lancamentoComparavel) {
                case let (x?, y?) where x != y: crescente ? x < y : x > y
                case (nil, _?): false
                case (_?, nil): true
                default: Self.compararTexto(a.title, b.title, crescente: true) ?? false
                }
            }

        case .inclusao:
            return ordemDeInclusao(em: contexto, crescente: crescente)
        }
    }

    // Manual: coleção mostra a posição mais alta primeiro (é como já aparecia, com o mais
    // novo no topo); caixa mostra da posição 0 em diante. Sem posição vai pro fim.
    private func ordemManual(em contexto: ContextoDeOrdenacao) -> [DiscoModel] {
        switch contexto {
        case .colecao:
            return sorted { $0.posicao > $1.posicao }
        case .caixa:
            return sorted { a, b in
                switch (a.posicaoCaixa, b.posicaoCaixa) {
                case let (x?, y?): x < y
                case (_?, nil): true
                default: false
                }
            }
        }
    }

    // Inclusão: usa a data; discos antigos sem data caem na ordem em que foram colocados
    private func ordemDeInclusao(em contexto: ContextoDeOrdenacao, crescente: Bool) -> [DiscoModel] {
        sorted { a, b in
            let dataA = contexto == .caixa ? a.adicionadoNaCaixaEm : a.adicionadoNaColecaoEm
            let dataB = contexto == .caixa ? b.adicionadoNaCaixaEm : b.adicionadoNaColecaoEm
            if let dataA, let dataB, dataA != dataB {
                return crescente ? dataA < dataB : dataA > dataB
            }
            let posicaoA = contexto == .caixa ? (a.posicaoCaixa ?? Int.max) : a.posicao
            let posicaoB = contexto == .caixa ? (b.posicaoCaixa ?? Int.max) : b.posicao
            return crescente ? posicaoA < posicaoB : posicaoA > posicaoB
        }
    }

    /// nil = empate (passa pro próximo critério)
    private static func compararTexto(_ a: String, _ b: String, crescente: Bool) -> Bool? {
        let resultado = a.localizedStandardCompare(b)
        guard resultado != .orderedSame else { return nil }
        return crescente ? resultado == .orderedAscending : resultado == .orderedDescending
    }
}

// MARK: - Ordem manual

extension Array where Element == DiscoModel {
    /// Salva a ordem exibida como a ordem manual (chamado depois de arrastar um disco).
    /// Coleção: o primeiro da lista fica com a posição mais alta. Caixa: o primeiro fica com 0.
    func salvarComoOrdemManual(em contexto: ContextoDeOrdenacao) {
        switch contexto {
        case .colecao:
            for (indice, disco) in enumerated() {
                disco.posicao = count - 1 - indice
            }
        case .caixa:
            for (indice, disco) in enumerated() {
                disco.posicaoCaixa = indice
            }
        }
    }
}
