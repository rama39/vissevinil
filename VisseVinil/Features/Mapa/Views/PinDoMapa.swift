//
//  PinDoMapa.swift
//  VisseVinil
//

import SwiftUI

/*
 Pin desenhado por nós (em vez do Marker nativo) pra poder colocar o selo de favorito/fixado
 NA FRENTE do pin: o MapKit sempre desenha o Marker por cima de qualquer Annotation separada.
 A ponta de baixo fica exatamente na coordenada (use com anchor: .bottom).

 Visual pensado pra se misturar ao mapa sem contrastes bruscos: nada de preto ou branco
 puros; luz em creme, sombras em marrom/preto suaves e degradês dentro da própria cor.
 De trás pra frente:
  1. sombra no chão (elipse embaixo da ponta) + três sombras em camadas (contato, média e
     ambiente), cada uma mais larga e mais fraca: a borda do pin "se dissolve" no mapa
  2. anel fino de Liquid Glass levemente creme em volta (o vidro fica só na borda: por cima da
     cor ele desbotava tudo sobre o mapa claro)
  3. miolo com degradê da própria cor (mais clara em cima, mais escura embaixo)
  4. brilho creme na borda do miolo, mais forte em cima (luz vindo de cima)
  5. símbolo com sombra suave, "gravado" no pin
*/
struct PinDoMapa: View {
    struct Selo {
        let icone: String
        let cor: Color
        var corDoIcone: Color = .creme
        var claro = false
    }

    /*
     Forma diferencia a categoria (não só a cor, o que ajuda também quem tem daltonismo):
      - retangulo: lugares fixos do app (lojas cadastradas), como as estações no Mapas
      - circulo: lugares do usuário (busca, favoritos, fixados)
    */
    enum Formato {
        case circulo
        case retangulo
    }

    let cor: Color
    let icone: String
    var corDoIcone: Color = .creme
    var formato: Formato = .circulo
    // Sem tons escuros: degradê só clareia (usado no favorito)
    var claro = false
    var selo: Selo?
    let selecionado: Bool

    // Miolo colorido + anel de vidro em volta
    private var tamanho: CGFloat { selecionado ? 58 : 31 }
    private var anel: CGFloat { selecionado ? 3 : 2 }

    // Cantos concêntricos: o anel de fora tem o raio do miolo + a espessura do anel
    private func forma(folga: CGFloat = 0) -> AnyShape {
        switch formato {
        case .circulo:
            AnyShape(Circle())
        case .retangulo:
            AnyShape(RoundedRectangle(cornerRadius: tamanho * 0.3 + folga, style: .continuous))
        }
    }

    var body: some View {
        VStack(spacing: -1.5) {
            cabeca

            PontaDoPin()
                .fill(Profundidade.escurecida(cor, claro: claro))
                .frame(width: selecionado ? 14 : 9, height: selecionado ? 10 : 6)
        }
        .modifier(SombrasDeProfundidade(elevado: selecionado))
        // Sombra no chão, embaixo da ponta (background não muda o tamanho, então a ponta
        // continua exatamente na coordenada)
        .background(alignment: .bottom) {
            Ellipse()
                .fill(Color.sombra.opacity(0.28))
                .frame(width: selecionado ? 22 : 12, height: selecionado ? 7 : 4.5)
                .blur(radius: 2.5)
                .offset(y: 2)
        }
        // Mola sem quique exagerado: cresce de forma fluida
        .animation(.spring(duration: 0.4, bounce: 0.15), value: selecionado)
    }

    private var cabeca: some View {
        Image(systemName: icone)
            .font(.system(size: tamanho * 0.46, weight: .semibold))
            .foregroundStyle(corDoIcone)
            .modifier(SombraDoSimbolo(claro: claro))
            .frame(width: tamanho, height: tamanho)
            .background {
                forma().fill(Profundidade.miolo(cor, claro: claro))
            }
            .overlay {
                forma()
                    .stroke(Profundidade.brilhoDaBorda, lineWidth: 0.75)
                    .padding(0.375)
            }
            // Anel de vidro: o miolo sólido fica por cima, então só a borda mostra o vidro
            .padding(anel)
            .glassEffect(.regular.tint(Color.creme.opacity(0.3)).interactive(), in: forma(folga: anel))
            .overlay(alignment: .topTrailing) {
                if let selo {
                    SeloDoPin(selo: selo, grande: selecionado)
                        .offset(x: selecionado ? 8 : 5, y: selecionado ? -8 : -5)
                }
            }
    }
}

private struct SeloDoPin: View {
    let selo: PinDoMapa.Selo
    let grande: Bool

    var body: some View {
        Image(systemName: selo.icone)
            .font(.system(size: grande ? 11 : 7.5, weight: .bold))
            .foregroundStyle(selo.corDoIcone)
            .modifier(SombraDoSimbolo(claro: selo.claro))
            .frame(width: grande ? 22 : 15, height: grande ? 22 : 15)
            .background(Circle().fill(Profundidade.miolo(selo.cor, claro: selo.claro)))
            .overlay(Circle().stroke(Color.creme, lineWidth: 1.5))
            .shadow(color: Color.sombra.opacity(0.4), radius: 2, y: 1)
    }
}

/// Bolha de agrupamento: creme (a cor mais próxima do mapa) com número marrom, pra
/// chamar atenção sem "pular" da tela. No modo escuro vira marrom claro com número creme.
/// Mesmo vidro e sombras dos pins.
struct BolhaDeAgrupamento: View {
    let quantidade: Int

    // Miolo + anel fino de vidro = 78 pt. Como o creme é quase a cor do mapa, quem separa a
    // bolha do fundo são as sombras (e não uma borda grossa)
    private let tamanho: CGFloat = 74
    private let anel: CGFloat = 2

    var body: some View {
        Text("+\(quantidade)")
            .font(.system(size: 22, weight: .bold, design: .rounded))
            .foregroundStyle(Color.textoDoAgrupamento)
            .frame(width: tamanho, height: tamanho)
            .background(Circle().fill(Profundidade.miolo(.fundoDoAgrupamento)))
            .overlay {
                // Aro interno quase imperceptível, só pra definir o contorno
                Circle()
                    .stroke(Color.textoDoAgrupamento.opacity(0.12), lineWidth: 0.75)
                    .padding(0.375)
            }
            .padding(anel)
            .glassEffect(.regular.tint(Color.creme.opacity(0.3)).interactive(), in: .circle)
            .modifier(SombrasDeProfundidade(elevado: false, intensidade: 1.25))
            .accessibilityElement()
            .accessibilityLabel("\(quantidade) lugares agrupados")
            .accessibilityHint("Toque para aproximar")
            .accessibilityAddTraits(.isButton)
    }
}

/// Ícone das listas (busca, fixados, favoritos, recentes), com a mesma forma e cor do pin no
/// mapa, pra pessoa reconhecer o tipo de lugar nos dois lugares.
struct IconeDeLocal: View {
    let cor: Color
    let icone: String
    var corDoIcone: Color = .creme
    var formato: PinDoMapa.Formato = .circulo
    var claro = false
    var tamanho: CGFloat = 30

    var body: some View {
        Image(systemName: icone)
            .font(.system(size: tamanho * 0.46, weight: .semibold))
            .foregroundStyle(corDoIcone)
            .modifier(SombraDoSimbolo(claro: claro))
            .frame(width: tamanho, height: tamanho)
            .background(forma.fill(Profundidade.miolo(cor, claro: claro)))
            .overlay(forma.stroke(Profundidade.brilhoDaBorda, lineWidth: 1).padding(0.5))
            .accessibilityHidden(true)
    }

    private var forma: AnyShape {
        switch formato {
        case .circulo:
            AnyShape(Circle())
        case .retangulo:
            AnyShape(RoundedRectangle(cornerRadius: tamanho * 0.27, style: .continuous))
        }
    }
}

// Luz e sombra compartilhadas por pins, selos, bolhas e ícones
private enum Profundidade {
    // Degradê dentro da própria cor: puxa pro creme em cima e pro preto embaixo.
    // claro: sem tons escuros; só um brilho creme no topo e a própria cor do meio pra baixo,
    // que é onde fica o símbolo (assim o contraste do símbolo é o da cor base)
    static func miolo(_ cor: Color, claro: Bool = false) -> LinearGradient {
        if claro {
            return LinearGradient(
                stops: [
                    .init(color: cor.mix(with: .creme, by: 0.35), location: 0),
                    .init(color: cor, location: 0.45),
                    .init(color: cor, location: 1),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        return LinearGradient(
            colors: [cor.mix(with: .creme, by: 0.22), cor, escurecida(cor)],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static func escurecida(_ cor: Color, claro: Bool = false) -> Color {
        claro ? cor : cor.mix(with: .preto, by: 0.25)
    }

    // Brilho creme na borda, mais forte em cima
    static let brilhoDaBorda = LinearGradient(
        colors: [Color.creme.opacity(0.9), Color.creme.opacity(0.25), Color.creme.opacity(0.05)],
        startPoint: .top,
        endPoint: .bottom
    )
}

// Símbolo "gravado" no pin. No pin claro a sombra é marrom (em vez de preta), o que mantém
// o símbolo creme legível sobre o amarelo sem escurecer o pin.
private struct SombraDoSimbolo: ViewModifier {
    let claro: Bool

    func body(content: Content) -> some View {
        content.shadow(color: claro ? Color.marrom.opacity(0.55) : Color.preto.opacity(0.3),
                       radius: claro ? 1.2 : 0.8, y: 0.8)
    }
}

/*
 Três sombras quentes em camadas, cada uma mais larga e mais fraca que a anterior. Juntas
 imitam uma sombra real (escura perto do objeto, se espalhando e sumindo no mapa), o que
 separa o pin do fundo sem precisar de borda grossa.
  - contato: bem curta, "cola" o pin no mapa
  - média: dá o volume
  - ambiente: larga e difusa, mistura o pin com o mapa (cresce quando selecionado)
*/
private struct SombrasDeProfundidade: ViewModifier {
    let elevado: Bool
    var intensidade: Double = 1

    func body(content: Content) -> some View {
        content
            .shadow(color: Color.preto.opacity(0.16 * intensidade), radius: 1, y: 0.5)
            .shadow(color: Color.sombra.opacity(0.22 * intensidade),
                    radius: elevado ? 6 : 3.5, y: elevado ? 4 : 2.5)
            .shadow(color: Color.sombra.opacity((elevado ? 0.26 : 0.18) * intensidade),
                    radius: elevado ? 24 : 12, y: elevado ? 16 : 7)
    }
}

private struct PontaDoPin: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.minX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

#Preview {
    VStack(spacing: 32) {
        HStack(spacing: 24) {
            PinDoMapa(cor: .marrom, icone: "storefront", formato: .retangulo, selecionado: false)
            PinDoMapa(cor: .marrom, icone: "storefront", formato: .retangulo,
                      selo: .init(icone: "star.fill", cor: .mostarda, claro: true), selecionado: false)
            PinDoMapa(cor: .mostarda, icone: "star.fill", claro: true, selecionado: false)
            PinDoMapa(cor: .vinho, icone: "pin.fill", selecionado: false)
            PinDoMapa(cor: .vinhoSuave, icone: "mappin", selecionado: false)
        }
        HStack(spacing: 24) {
            PinDoMapa(cor: .marrom, icone: "storefront", formato: .retangulo,
                      selo: .init(icone: "star.fill", cor: .mostarda, claro: true), selecionado: true)
            BolhaDeAgrupamento(quantidade: 4)
        }
    }
    .padding(40)
    .background(Color(red: 0.95, green: 0.92, blue: 0.87))
}
