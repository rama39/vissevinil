//
//  EnquadramentoDoMapa.swift
//  VisseVinil
//

import MapKit
import SwiftUI

/// Contas de câmera do mapa (sem estado): onde centralizar e com qual zoom.
enum EnquadramentoDoMapa {
    struct Foco {
        let regiao: MKCoordinateRegion
        /// true = manteve o zoom da pessoa (toque num pin visível)
        let manteveZoom: Bool
    }

    /*
     Região que deixa o local logo acima da sheet reduzida. Tudo é medido no próprio mapa,
     no estado atual, com o MapProxy:
      1. Pega a coordenada que está no ponto-alvo da tela (logo acima da sheet).
      2. A diferença entre ela e o centro da região é "quanto o centro precisa ficar
         deslocado do local" no zoom atual.
      3. Esse deslocamento escala linearmente com o zoom, então pra ir pro zoom padrão
         basta multiplicar pela proporção entre o span novo e o atual.
     Toque num pin visível mantém zoom e posição horizontal; busca/recentes/favoritos (ou
     local fora da tela) usam o zoom padrão, centralizado na horizontal.
    */
    static func focoAcimaDaSheet(em coordenada: CLLocationCoordinate2D,
                                 regiaoAtual regiao: MKCoordinateRegion,
                                 tamanhoDoMapa: CGSize,
                                 mapProxy: MapProxy,
                                 zoomPadrao: Bool) -> Foco? {
        guard tamanhoDoMapa.height > 0, regiao.span.latitudeDelta > 0,
              let pontoCentro = mapProxy.convert(regiao.center, to: .local) else { return nil }

        let pontoDoLocal = mapProxy.convert(coordenada, to: .local)
        let localNaTela = pontoDoLocal.map {
            $0.x >= 0 && $0.x <= tamanhoDoMapa.width && $0.y >= 0 && $0.y <= tamanhoDoMapa.height
        } ?? false

        let manterZoom = !zoomPadrao && localNaTela
        let proporcao = manterZoom ? 1 : ConfiguracaoDoMapa.spanDeFoco / regiao.span.latitudeDelta
        let xAlvo = manterZoom ? (pontoDoLocal?.x ?? pontoCentro.x) : pontoCentro.x
        let yAlvo = max(tamanhoDoMapa.height - ConfiguracaoDoMapa.alturaDaSheetReduzida
                            - ConfiguracaoDoMapa.espacamentoAcimaDaSheet,
                        tamanhoDoMapa.height * 0.25)

        guard let coordenadaNoAlvo = mapProxy.convert(CGPoint(x: xAlvo, y: yAlvo), from: .local) else { return nil }

        let deslocamentoLat = (coordenadaNoAlvo.latitude - regiao.center.latitude) * proporcao
        let deslocamentoLon = (coordenadaNoAlvo.longitude - regiao.center.longitude) * proporcao

        let novoCentro = CLLocationCoordinate2D(
            latitude: coordenada.latitude - deslocamentoLat,
            longitude: coordenada.longitude - deslocamentoLon
        )
        // Mantém a proporção largura/altura da região visível, pra ela caber exatamente na tela
        let novoSpan = MKCoordinateSpan(
            latitudeDelta: regiao.span.latitudeDelta * proporcao,
            longitudeDelta: regiao.span.longitudeDelta * proporcao
        )
        return Foco(regiao: MKCoordinateRegion(center: novoCentro, span: novoSpan), manteveZoom: manterZoom)
    }

    /// Região que mostra todas as lojas de um grupo. `pertoDemais` = nem o zoom máximo separa
    /// as lojas (ex: Pulga e Taberna, a ~20 m), então o grupo precisa ser separado à força.
    static func regiaoDoGrupo(_ lojas: [Loja]) -> (regiao: MKCoordinateRegion, pertoDemais: Bool)? {
        let latitudes = lojas.map(\.latitude)
        let longitudes = lojas.map(\.longitude)

        guard let latMin = latitudes.min(), let latMax = latitudes.max(),
              let lonMin = longitudes.min(), let lonMax = longitudes.max() else { return nil }

        let centro = CLLocationCoordinate2D(latitude: (latMin + latMax) / 2, longitude: (lonMin + lonMax) / 2)
        let span = MKCoordinateSpan(
            latitudeDelta: max((latMax - latMin) * 2.2, 0.0015),
            longitudeDelta: max((lonMax - lonMin) * 2.2, 0.0015)
        )

        // Cálculo à parte, SÓ pra decidir se é um caso "sem solução por zoom"; não afeta a câmera
        let localizacaoCentro = CLLocation(latitude: centro.latitude, longitude: centro.longitude)
        let raioMaximo = lojas
            .map { CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: localizacaoCentro) }
            .max() ?? 0

        return (MKCoordinateRegion(center: centro, span: span), raioMaximo * 3 < ConfiguracaoDoMapa.distanciaMinima)
    }

    /// Câmera inicial: segue o usuário se ele estiver na região; senão mostra a cidade inteira.
    static func cameraInicial(para localizacao: CLLocationCoordinate2D?) -> MapCameraPosition {
        let regiao = ConfiguracaoDoMapa.regiaoMetropolitana
        guard let localizacao, regiao.isIn(localizacao) else {
            return .region(regiao)
        }
        return .userLocation(fallback: .region(regiao))
    }
}
