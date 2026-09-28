//
//  CorrespondenciaDeLocais.swift
//  VisseVinil
//

import CoreLocation

/*
 Descobre se um local (resultado de busca, recente, favorito) é uma loja já conhecida.
 O MapKit raramente devolve exatamente a mesma coordenada que cadastramos, então só a
 distância (40 m) deixava a loja passar como "local avulso" (pin duplicado), ou casava com
 a vizinha errada (Pulga e Taberna ficam a ~20 m). Por isso o nome tem prioridade.
*/
enum CorrespondenciaDeLocais {
    /// Mesmo nome até 500 m; senão, o mais perto até 40 m.
    static func correspondente(_ loja: Loja, em candidatas: [Loja]) -> Loja? {
        let alvo = CLLocation(latitude: loja.latitude, longitude: loja.longitude)

        let comDistancia = candidatas.map { candidata in
            (loja: candidata,
             distancia: CLLocation(latitude: candidata.latitude, longitude: candidata.longitude).distance(from: alvo))
        }

        let porNome = comDistancia.filter { item in
            item.loja.nameForSearch.pareceONomeDe(loja.nameForSearch) && item.distancia < 500
        }
        if let melhor = porNome.min(by: { $0.distancia < $1.distancia }) {
            return melhor.loja
        }

        return comDistancia
            .filter { $0.distancia < 40 } // metros de tolerância
            .min(by: { $0.distancia < $1.distancia })?
            .loja
    }

    /// Um local salvo (ex: recente) é uma das lojas cadastradas?
    static func ehLojaCadastrada(_ salvo: LocalSalvo, em lojas: [Loja]) -> Bool {
        let posicao = CLLocation(latitude: salvo.latitude, longitude: salvo.longitude)
        return lojas.contains {
            $0.nameForSearch.pareceONomeDe(salvo.nome)
                && CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: posicao) < 500
        }
    }
}
