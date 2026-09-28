//
//  EstiloDeLocal.swift
//  VisseVinil
//

import SwiftUI

/*
 Visual de cada tipo de lugar, usado igual no pin do mapa e no ícone das listas:
  - loja cadastrada: quadrado marrom com vitrine (+ selo de estrela se favorita, ou de alfinete se fixada)
  - local avulso favorito: mostarda com brilho dourado e estrela creme (+ selo de alfinete se também fixado)
  - local avulso só fixado: vinho com alfinete
  - resultado de busca (não salvo): vinho desbotado
  - recente / termo de busca: cinza
 Cores da paleta do app (Assets > Paleta). Símbolo sempre creme; o favorito é "claro" (sem tons escuros).
*/
struct EstiloDeLocal {
    let cor: Color
    let icone: String
    var corDoIcone: Color = .creme
    var claro = false
    var formato: PinDoMapa.Formato = .circulo
    var selo: PinDoMapa.Selo? = nil

    static let lojaCadastrada = EstiloDeLocal(cor: .marrom, icone: "storefront", formato: .retangulo)
    static let naoSalvo = EstiloDeLocal(cor: .vinhoSuave, icone: "mappin")
    static let recente = EstiloDeLocal(cor: .cinzaEscuro, icone: "clock.fill")
    static let termoDeBusca = EstiloDeLocal(cor: .cinzaEscuro, icone: "magnifyingglass")

    private static let seloEstrela = PinDoMapa.Selo(icone: "star.fill", cor: .mostarda, claro: true)
    private static let seloAlfinete = PinDoMapa.Selo(icone: "pin.fill", cor: .vinho)

    static func local(cadastrado: Bool, favorito: Bool, fixado: Bool) -> EstiloDeLocal {
        if cadastrado {
            var estilo = lojaCadastrada
            estilo.selo = favorito ? seloEstrela : (fixado ? seloAlfinete : nil)
            return estilo
        }
        if favorito {
            return EstiloDeLocal(cor: .mostarda, icone: "star.fill", claro: true,
                                 selo: fixado ? seloAlfinete : nil)
        }
        if fixado {
            return EstiloDeLocal(cor: .vinho, icone: "pin.fill")
        }
        // Local não salvo: vinho desbotado, mais discreto que os salvos
        return naoSalvo
    }
}

extension LocaisSalvosStore {
    /// Estilo de um local conforme ele é loja cadastrada, favorito e/ou fixado
    func estilo(para loja: Loja) -> EstiloDeLocal {
        .local(cadastrado: ehLojaCadastrada(loja), favorito: ehFavorito(loja), fixado: ehFixado(loja))
    }
}

extension PinDoMapa {
    init(estilo: EstiloDeLocal, selecionado: Bool) {
        self.init(cor: estilo.cor, icone: estilo.icone, corDoIcone: estilo.corDoIcone,
                  formato: estilo.formato, claro: estilo.claro, selo: estilo.selo,
                  selecionado: selecionado)
    }
}

extension IconeDeLocal {
    init(estilo: EstiloDeLocal, tamanho: CGFloat = 30) {
        self.init(cor: estilo.cor, icone: estilo.icone, corDoIcone: estilo.corDoIcone,
                  formato: estilo.formato, claro: estilo.claro, tamanho: tamanho)
    }
}
