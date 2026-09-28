//
//  FormatoDeRota.swift
//  VisseVinil
//

import Foundation
import CoreLocation

// nonisolated: só formata texto, pode rodar em qualquer thread (o projeto usa MainActor por padrão)
nonisolated enum FormatoDeRota {
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
