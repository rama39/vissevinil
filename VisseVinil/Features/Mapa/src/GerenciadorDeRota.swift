//
//  GerenciadorDeRota.swift
//  VisseVinil
//

import MapKit

/// A rota em si é feita no app Mapas (navegação, trajeto, transporte); aqui só calculamos
/// o tempo estimado a pé pro botão da sheet e abrimos o Mapas já com a rota traçada.
enum RotaNoMapas {
    /// Tempo estimado a pé do usuário até o destino.
    static func tempoAPe(de origem: CLLocationCoordinate2D, ate destino: CLLocationCoordinate2D) async -> TimeInterval? {
        let pedido = MKDirections.Request()
        pedido.source = MKMapItem(location: CLLocation(latitude: origem.latitude, longitude: origem.longitude),
                                  address: nil)
        pedido.destination = MKMapItem(location: CLLocation(latitude: destino.latitude, longitude: destino.longitude),
                                       address: nil)
        pedido.transportType = .walking
        return try? await MKDirections(request: pedido).calculateETA().expectedTravelTime
    }

    /// Abre o app Mapas com a rota a pé até o local já traçada (a pessoa pode trocar o
    /// transporte e iniciar a navegação por lá).
    static func abrirRota(ate loja: Loja) {
        let destino = MKMapItem(location: CLLocation(latitude: loja.latitude, longitude: loja.longitude),
                                address: nil)
        destino.name = loja.officialName ?? loja.nameForSearch
        destino.phoneNumber = loja.fone
        destino.url = loja.website.flatMap(URL.init(string:))

        destino.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
}

enum FormatoDeRota {
    /// "12 min", "1 h 5 min"
    static func tempo(_ segundos: TimeInterval) -> String {
        Duration.seconds(max(segundos, 60))
            .formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
    }

    /// "850 m", "2,3 km"
    static func distancia(_ metros: CLLocationDistance) -> String {
        Measurement(value: metros, unit: UnitLength.meters)
            .formatted(.measurement(width: .abbreviated, usage: .road))
    }
}
