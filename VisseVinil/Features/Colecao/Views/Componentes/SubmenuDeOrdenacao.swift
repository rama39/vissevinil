//
//  SubmenuDeOrdenacao.swift
//  VisseVinil
//

import SwiftUI

/*
 Submenu "Ordenar Por", como no app Notas: fica dentro do menu "…" da tela e mostra o
 critério atual como subtítulo. Dentro: os critérios (escolha única com ✓) e, logo abaixo,
 a direção com nomes que fazem sentido pro critério ("A a Z", "Mais Recentes Primeiro").
 Manual não tem direção: a ordem é a que a pessoa montou arrastando os discos.
*/
struct SubmenuDeOrdenacao: View {
    @Binding var ordenacao: Ordenacao
    @Binding var crescente: Bool
    let contexto: ContextoDeOrdenacao

    var body: some View {
        Menu {
            Picker("Ordenar Por", selection: criterio) {
                ForEach(Ordenacao.allCases) { opcao in
                    Label(opcao.titulo(em: contexto), systemImage: opcao.icone).tag(opcao)
                }
            }
            .pickerStyle(.inline)

            if ordenacao.temDirecao {
                Picker("Direção", selection: $crescente) {
                    // A direção natural do critério vem primeiro
                    ForEach([ordenacao.crescentePorPadrao, !ordenacao.crescentePorPadrao], id: \.self) { valor in
                        Label(ordenacao.rotuloDaDirecao(crescente: valor),
                              systemImage: ordenacao.iconeDaDirecao(crescente: valor))
                            .tag(valor)
                    }
                }
                .pickerStyle(.inline)
            }
        } label: {
            Label {
                Text("Ordenar Por")
                // Subtítulo no menu com o critério atual
                Text(ordenacao.titulo(em: contexto))
            } icon: {
                Image(systemName: "arrow.up.arrow.down")
            }
        }
    }

    // Trocar de critério volta pra direção natural dele (ex: Título → A a Z)
    private var criterio: Binding<Ordenacao> {
        Binding(
            get: { ordenacao },
            set: { novo in
                ordenacao = novo
                crescente = novo.crescentePorPadrao
            }
        )
    }
}
