//
//  CaixaView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import SwiftUI

struct CaixaView: View {

    /// Como ver os discos da caixa (escolha salva no aparelho)
    private enum Visualizacao: String, CaseIterable, Identifiable {
        case lista
        case caixa
        var id: String { rawValue }
        var titulo: String {
            switch self {
            case .lista: "Ver como Lista"
            case .caixa: "Ver como Caixa"
            }
        }
        var icone: String {
            switch self {
            case .lista: "list.bullet"
            case .caixa: "square.stack.3d.down.forward"
            }
        }
    }

    @Bindable var caixa: CaixaModel

    @AppStorage("colecao.caixa.visualizacao") private var visualizacao: Visualizacao = .lista

    @State private var bufferBusca = ""
    var discosBuscados: [DiscoModel] {
        caixa.discos
        .filter { disco in
            bufferBusca.isEmpty ||
            disco.title.localizedCaseInsensitiveContains(bufferBusca)
        }
        .filter({!$0.removed})
        .ordenados(por: caixa.ordenacao, crescente: caixa.ordemCrescente, em: .caixa)
    }

    // Arrastar só faz sentido na lista, na ordem manual e com a caixa inteira (sem busca)
    private var podeReordenar: Bool {
        visualizacao == .lista && caixa.ordenacao == .manual && bufferBusca.isEmpty
    }

    @State var adicionandoDisco: Bool = false
    @State private var discoAberto: DiscoModel?

    var body: some View {
        Group {
            switch visualizacao {
            case .lista:
                lista
            case .caixa:
                if discosBuscados.isEmpty {
                    ContentUnavailableView(bufferBusca.isEmpty ? "Caixa vazia" : "Nenhum disco encontrado",
                                           systemImage: "square.stack.3d.down.forward")
                } else {
                    CaixaFolheavelView(discos: discosBuscados) { disco in
                        discoAberto = disco
                    }
                }
            }
        }
        .navigationTitle($caixa.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $discoAberto) { disco in
            DiscoView(disco: disco)
        }
        .toolbar {
            if podeReordenar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    adicionandoDisco.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
            // "…" como no app Notas: forma de ver + "Ordenar Por"
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Visualização", selection: $visualizacao) {
                        ForEach(Visualizacao.allCases) { opcao in
                            Label(opcao.titulo, systemImage: opcao.icone).tag(opcao)
                        }
                    }
                    .pickerStyle(.inline)

                    SubmenuDeOrdenacao(ordenacao: $caixa.ordenacao, crescente: $caixa.ordemCrescente,
                                       contexto: .caixa)
                } label: {
                    Label("Mais opções", systemImage: "ellipsis")
                }
            }
        }
        .sheet(isPresented: $adicionandoDisco) {
            AddDiscoView(caixa: caixa, adicionandoDisco: $adicionandoDisco)
        }
        .searchable(text: $bufferBusca, prompt: "Pesquisar Discos da Caixa")
    }

    private var lista: some View {
        List {
            ForEach(discosBuscados) { disco in
                NavigationLink {
                    DiscoView(disco: disco)
                } label: {
                    ColecaoPesquisaRow(disco: disco, inCaixa: true)
                }
            }
            .onDelete(perform: deleteItems)
            .onMove(perform: acaoDeMover)
        }
    }

    // nil desliga o arrastar (a lista só deixa mover quando há uma ação)
    private var acaoDeMover: ((IndexSet, Int) -> Void)? {
        guard podeReordenar else { return nil }
        return { origem, destino in moverDiscos(de: origem, para: destino) }
    }

    // Salva a nova ordem como ordem manual (o app lembra onde cada disco está na caixa).
    // Os discos tirados pra ouvir (fora da lista) ficam depois, na ordem em que estavam.
    private func moverDiscos(de origem: IndexSet, para destino: Int) {
        var lista = discosBuscados
        lista.move(fromOffsets: origem, toOffset: destino)
        let tiradosParaOuvir = caixa.discos
            .filter(\.removed)
            .ordenados(por: .manual, crescente: true, em: .caixa)
        (lista + tiradosParaOuvir).salvarComoOrdemManual(em: .caixa)
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let deletado = discosBuscados[index]
                for disco in caixa.discos {
                    if let pos0 = disco.posicaoCaixa,
                       let pos1 = deletado.posicaoCaixa,
                       pos0 > pos1 {
                        disco.posicaoCaixa = pos0 - 1
                    }
                }
                deletado.posicaoCaixa = nil
                deletado.adicionadoNaCaixaEm = nil
                deletado.caixa = nil
            }
        }
    }
}

//#Preview {
//    CaixaView()
//}
