//
//  SugestoesDeBuscaView.swift
//  VisseVinil
//

import SwiftUI
import MapKit

/// Resultados enquanto digita: lista simples, com o trecho digitado em destaque.
struct SugestoesDeBuscaView: View {
    let sugestoes: [MKLocalSearchCompletion]
    let lojasCadastradas: [Loja]
    let selecionar: (MKLocalSearchCompletion) -> Void

    var body: some View {
        List(sugestoes, id: \.self) { sugestao in
            LinhaDeLocal(titulo: tituloDestacado(sugestao), subtitulo: sugestao.subtitle,
                         estilo: estilo(da: sugestao)) {
                selecionar(sugestao)
            }
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(.ultraThinMaterial)
        .scrollEdgeEffectStyle(.soft, for: .all)
        .scrollDismissesKeyboard(.immediately)
    }

    // Deixa em negrito a parte do título que bate com o que foi digitado (igual ao Mapas)
    private func tituloDestacado(_ sugestao: MKLocalSearchCompletion) -> Text {
        var titulo = AttributedString(sugestao.title)
        for valor in sugestao.titleHighlightRanges {
            if let intervalo = Range(valor.rangeValue, in: titulo) {
                titulo[intervalo].font = .body.weight(.semibold)
            }
        }
        return Text(titulo)
    }

    // Sugestão sem subtítulo é uma busca por termo ("vinil"); com subtítulo é um lugar
    private func estilo(da sugestao: MKLocalSearchCompletion) -> EstiloDeLocal {
        if sugestao.subtitle.isEmpty {
            return .termoDeBusca
        }
        if lojasCadastradas.contains(where: { $0.nameForSearch.pareceONomeDe(sugestao.title) }) {
            return .lojaCadastrada
        }
        return .naoSalvo
    }
}
