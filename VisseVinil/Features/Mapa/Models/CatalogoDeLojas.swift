//
//  CatalogoDeLojas.swift
//  VisseVinil
//

import CoreLocation

/*
 Lojas cadastradas "à mão". São gravadas no SwiftData na primeira abertura
 (SincronizacaoDeLojas) e depois atualizadas pela internet a cada 20 dias (StoreSearch).
 O nome é o identificador da loja; a coordenada daqui é a referência pra validar as
 atualizações (um resultado muito longe dela provavelmente é outro lugar).
*/
enum CatalogoDeLojas {
    struct Item {
        let nome: String
        let latitude: Double
        let longitude: Double

        var coordenada: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }

    static let itens: [Item] = [
        Item(nome: "R Vinil e CDs", latitude: -8.03734, longitude: -34.89216),
        Item(nome: "Vinil Alternativo", latitude: -8.06214, longitude: -34.88369),
        Item(nome: "Pulga Mercado de Discos", latitude: -8.03924, longitude: -34.89467),
        Item(nome: "Taberna do Vinil", latitude: -8.03940, longitude: -34.89471),
        Item(nome: "Bolacha Discos e Coisas", latitude: -8.04789, longitude: -34.89889),
        Item(nome: "Disco de Ouro", latitude: -8.06040, longitude: -34.88291),
        Item(nome: "Blackout Discos", latitude: -8.06003, longitude: -34.88234),
        Item(nome: "Flowers Records Brazil", latitude: -8.06222, longitude: -34.88272),
        Item(nome: "CD & Cia", latitude: -8.06209, longitude: -34.88209),
        Item(nome: "Sebo Pereira", latitude: -8.05799, longitude: -34.88632),
        Item(nome: "Praça do Sebo (Estandes Diversos)", latitude: -8.06306, longitude: -34.87872),
        Item(nome: "Fernando Vinil Discos", latitude: -8.04147, longitude: -34.89415),
        Item(nome: "Sebo da Torre", latitude: -8.04526, longitude: -34.90721),
    ]

    /// Coordenada cadastrada de cada loja, pelo nome
    static var referencias: [String: CLLocationCoordinate2D] {
        Dictionary(uniqueKeysWithValues: itens.map { ($0.nome, $0.coordenada) })
    }

    /// Nome da loja do catálogo que fica nessa coordenada (até 40 m). Usado pra migrar
    /// favoritos antigos, que eram identificados só pela coordenada.
    static func nomeDaLoja(latitude: Double, longitude: Double) -> String? {
        let alvo = CLLocation(latitude: latitude, longitude: longitude)
        return itens.first {
            CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: alvo) < 40
        }?.nome
    }
}
