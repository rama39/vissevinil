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
