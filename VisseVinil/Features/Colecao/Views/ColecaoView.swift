//
//  ColecaoView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import SwiftUI

struct ColecaoView: View {
    
    private enum ModeoVisualizacao: String, CaseIterable, Identifiable {
        case discos
        case caixas
        var id: String { self.rawValue }
        var iconName: String {
            switch self {
            case .discos: return "list.bullet.rectangle.portrait"
            case .caixas: return "square.stack"
            }
        }
    }
    
    @AppStorage("Modo de Visualização da Coleção (discos/caixas)")
    private var modoVisualizacao: ModeoVisualizacao = .caixas

    // Ordenação da lista de discos (salva no aparelho; a ColecaoPesquisaView lê as mesmas chaves)
    @AppStorage("colecao.ordenacao") private var ordenacao: Ordenacao = .inclusao
    @AppStorage("colecao.ordemCrescente") private var ordemCrescente = false
    
    var body: some View {
        NavigationStack {
            Group {
                switch modoVisualizacao {
                case .caixas:
                    CaixasGridView()
                        .navigationTitle("Caixas da Coleção")
                        .navigationSubtitle("Registre onde seus discos de vinil estão")
                default:
                    ColecaoPesquisaView()
                        .navigationTitle("Discos da Coleção")
                }
            }
//            .toolbar {
//                ToolbarItem(placement: .topBarLeading) {
//                    Menu {
//                        Picker("", selection: $modoVisualizacao) {
//                            ForEach(ModeoVisualizacao.allCases) { modo in
//                                Label(modo.rawValue, systemImage: modo.iconName)
//                                    .tag(modo)
//                            }
//                        }
//
//                        if modoVisualizacao == .discos {
//                            SubmenuDeOrdenacao(ordenacao: $ordenacao, crescente: $ordemCrescente,
//                                               contexto: .colecao)
//                        }
//                    } label: {
//                        Image(systemName: "ellipsis")
//                    }
//                }
//            }
        }
    }
}

#Preview {
    ColecaoView()
}
