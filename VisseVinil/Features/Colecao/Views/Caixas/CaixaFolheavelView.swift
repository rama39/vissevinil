//
//  CaixaFolheavelView.swift
//  VisseVinil
//

import SwiftUI
import SwiftData

/*
 Caixa vista de cima, folheando os discos (como num sebo).
  - O disco em foco fica de pé, no centro. Os próximos ficam atrás dele (acima na tela),
    cada vez menores e mais escuros, mostrando só o topo. O que passa tomba pra frente
    (pra baixo) e some durante o movimento.
  - Rolagem vertical nativa (ScrollView), com "encaixe" em cada disco: mantém a inércia e a
    acessibilidade do sistema, em vez de um gesto próprio. Arrastar pra baixo puxa o disco da
    frente na sua direção e revela o próximo.
  - Título e artista do disco em foco ficam fixos embaixo. Tocar no disco em foco abre o
    detalhe; tocar em outro traz ele pra frente.
  - Com "Reduzir Movimento" ligado, os discos ficam retos (sem 3D).
  - Visual do Cover Flow do iTunes: cada capa tem um reflexo embaixo, como numa superfície
    de água, e a capa usa a imagem grande do Discogs (a miniatura de 150 px ficava borrada).
    Sem o desfoque da barra do topo, pra os discos de trás aparecerem nítidos.
*/
struct CaixaFolheavelView: View {
    let discos: [DiscoModel]
    let abrir: (DiscoModel) -> Void

    @Environment(\.accessibilityReduceMotion) private var reduzirMovimento
    @State private var discoEmFoco: PersistentIdentifier?

    var body: some View {
        GeometryReader { geometria in
            let lado = min(geometria.size.width * 0.74, geometria.size.height * 0.52)
            // Distância entre um disco e o próximo (o resto do quadrado fica sobreposto)
            let passo = lado * 0.3

            ScrollView(.vertical) {
                LazyVStack(spacing: passo - lado) {
                    // De trás pra frente: o primeiro disco da lista é o da frente (embaixo)
                    ForEach(discosDeTrasPraFrente, id: \.disco.persistentModelID) { item in
                        DiscoNaPilha(disco: item.disco, lado: lado, passo: passo,
                                     reduzirMovimento: reduzirMovimento,
                                     tocar: { tocar(item.disco) }, abrir: { abrir(item.disco) })
                            // Os da frente cobrem os de trás
                            .zIndex(Double(discos.count - item.indice))
                    }
                }
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollPosition(id: $discoEmFoco, anchor: .center)
            // Margens pra o primeiro e o último disco também poderem ficar no centro
            .contentMargins(.vertical, max((geometria.size.height - lado) / 2, 0), for: .scrollContent)
            .scrollIndicators(.hidden)
            .scrollEdgeEffectHidden(true, for: .top)
            .defaultScrollAnchor(.bottom)
            // Sem desfoque: perto da barra do topo os discos só vão sumindo (transparência),
            // nítidos até o fim, e o título da tela continua legível
            .mask {
                LinearGradient(
                    stops: [.init(color: .clear, location: 0),
                            .init(color: .black, location: 0.2)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        }
        .safeAreaInset(edge: .bottom) {
            legenda
        }
        .sensoryFeedback(.selection, trigger: discoEmFoco)
        .onAppear {
            if discoEmFoco == nil {
                discoEmFoco = discos.first?.persistentModelID
            }
        }
        .onChange(of: discos.map(\.persistentModelID)) { _, ids in
            // Disco em foco saiu (busca/ordenação): volta pro primeiro
            if let discoEmFoco, !ids.contains(discoEmFoco) {
                self.discoEmFoco = ids.first
            }
        }
    }

    // Do último pro primeiro: o primeiro disco da lista fica na frente (embaixo da pilha)
    private var discosDeTrasPraFrente: [(indice: Int, disco: DiscoModel)] {
        discos.enumerated().reversed().map { (indice: $0.offset, disco: $0.element) }
    }

    // MARK: - Legenda

    private var indiceEmFoco: Int? {
        discos.firstIndex { $0.persistentModelID == discoEmFoco }
    }

    @ViewBuilder
    private var legenda: some View {
        if let indiceEmFoco {
            let disco = discos[indiceEmFoco]
            VStack(spacing: 2) {
                Text(disco.title)
                    .font(.headline)
                    .lineLimit(1)
                Text(disco.artistsListed.isEmpty ? "Artista desconhecido" : disco.artistsListed)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text("\(indiceEmFoco + 1) de \(discos.count)")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .monospacedDigit()
                    .padding(.top, 2)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal)
            .padding(.vertical, 12)
            .contentTransition(.opacity)
            .animation(.easeInOut(duration: 0.2), value: indiceEmFoco)
            // A legenda já é lida em cada disco pelo VoiceOver
            .accessibilityHidden(true)
        }
    }

    // MARK: - Ações

    private func tocar(_ disco: DiscoModel) {
        if disco.persistentModelID == discoEmFoco {
            abrir(disco)
        } else {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                discoEmFoco = disco.persistentModelID
            }
        }
    }

}

/// Um disco da pilha: capa + efeito de folhear + toque e acessibilidade.
/// (Separado em uma view própria pra o compilador conferir os tipos rápido.)
private struct DiscoNaPilha: View {
    let disco: DiscoModel
    let lado: CGFloat
    let passo: CGFloat
    let reduzirMovimento: Bool
    let tocar: () -> Void
    let abrir: () -> Void

    var body: some View {
        CapaNaCaixa(disco: disco, lado: lado)
            .visualEffect { [passo, reduzirMovimento] conteudo, proxy in
                EfeitoDeFolhear.aplicar(em: conteudo, proxy: proxy, passo: passo,
                                        reduzirMovimento: reduzirMovimento)
            }
            .onTapGesture(perform: tocar)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(rotulo)
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { abrir() }
    }

    private var rotulo: String {
        disco.artistsListed.isEmpty ? disco.title : "\(disco.title), de \(disco.artistsListed)"
    }
}

/// Conta do efeito de cada disco a partir da distância (em discos) até o centro da caixa.
private enum EfeitoDeFolhear {
    nonisolated static func aplicar(em conteudo: EmptyVisualEffect, proxy: GeometryProxy,
                                    passo: CGFloat, reduzirMovimento: Bool) -> some VisualEffect {
        let altura = proxy.bounds(of: .scrollView)?.height ?? 0
        let centroDoDisco = proxy.frame(in: .scrollView).midY
        // 0 = em foco; negativo = atrás (acima); positivo = já passou (abaixo)
        let distancia = passo > 0 ? (centroDoDisco - altura / 2) / passo : 0

        let atras = max(-distancia, 0)
        let passou = max(distancia, 0)

        // Atrás: cada vez menor, mais escuro e levemente inclinado pra trás
        let escalaAtras = 1 - min(atras, 6) * 0.045
        let brilho = -min(atras, 6) * 0.07
        let inclinacaoAtras = min(atras, 3) * 6.0
        // Passou: tomba pra frente, desce pra baixo do disco em foco (sem cobri-lo) e some
        let tombo = min(passou, 1.5) * 70.0
        let descida = min(passou, 1.5) * passo * 1.5
        let escalaPassou = 1 - min(passou, 1.5) * 0.12
        // Some durante o tombo: parado, o disco que passou já não aparece (não cobre a legenda)
        let opacidade = max(0, 1 - passou * 1.3)

        guard !reduzirMovimento else {
            return conteudo
                .scaleEffect(1, anchor: .bottom)
                .rotation3DEffect(.zero, axis: (x: 1, y: 0, z: 0))
                .offset(y: 0)
                .brightness(brilho)
                .opacity(opacidade)
        }
        return conteudo
            .scaleEffect(escalaAtras * escalaPassou, anchor: .bottom)
            .rotation3DEffect(.degrees(inclinacaoAtras - tombo), axis: (x: 1, y: 0, z: 0),
                              anchor: .bottom, perspective: 0.3)
            .offset(y: descida)
            .brightness(brilho)
            .opacity(opacidade)
    }
}

/// Capa do disco em pé na caixa, com o reflexo embaixo (como no Cover Flow do iTunes).
private struct CapaNaCaixa: View {
    let disco: DiscoModel
    let lado: CGFloat

    @State private var imagemGrande: UIImage?

    // Reflexo: altura e quão visível ele começa (vai sumindo até 0)
    private var alturaDoReflexo: CGFloat { lado * 0.42 }
    private let opacidadeDoReflexo = 0.32

    var body: some View {
        capa
            .shadow(color: .black.opacity(0.28), radius: 12, y: 6)
            // Reflexo fora do tamanho do disco (não muda o espaçamento nem o encaixe)
            .background(alignment: .top) {
                reflexo
                    .offset(y: lado + 2)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
            }
            .contentShape(Rectangle())
            .task(id: disco.persistentModelID) {
                imagemGrande = await CacheDeCapas.imagemGrande(de: disco)
            }
    }

    private var capa: some View {
        imagem
            .frame(width: lado, height: lado)
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(.white.opacity(0.16), lineWidth: 1)
            }
    }

    // A capa de cabeça pra baixo, sumindo num degradê, como água refletindo
    private var reflexo: some View {
        capa
            .scaleEffect(x: 1, y: -1, anchor: .center)
            .frame(width: lado, height: alturaDoReflexo, alignment: .top)
            .clipped()
            .mask {
                LinearGradient(colors: [.white.opacity(opacidadeDoReflexo), .clear],
                               startPoint: .top, endPoint: .bottom)
            }
    }

    @ViewBuilder
    private var imagem: some View {
        if let imagemGrande {
            Image(uiImage: imagemGrande)
                .resizable()
                .interpolation(.high)
                .scaledToFill()
        } else if let miniatura = disco.coverImage {
            // Enquanto a imagem grande carrega (ou se não houver), usa a miniatura salva
            miniatura
                .resizable()
                .interpolation(.high)
                .scaledToFill()
        } else {
            ZStack {
                LinearGradient(colors: [Color(.systemGray5), Color(.systemGray6)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                Image(systemName: "opticaldisc")
                    .font(.system(size: lado * 0.2))
                    .foregroundStyle(.secondary)
            }
        }
    }
}
