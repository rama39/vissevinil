//
//  PermissaoDeLocalizacao.swift
//  VisseVinil
//

import CoreLocation
import Observation

/// Estado da permissão de localização e o pedido ao sistema (usado no começo do onboarding).
/// Só pede a permissão; quem usa a localização é o mapa (Locator).
@MainActor
@Observable
final class PermissaoDeLocalizacao: NSObject, CLLocationManagerDelegate {
    private let gerenciador = CLLocationManager()

    private(set) var status: CLAuthorizationStatus

    override init() {
        status = gerenciador.authorizationStatus
        super.init()
        gerenciador.delegate = self
    }

    var foiPermitida: Bool {
        status == .authorizedWhenInUse || status == .authorizedAlways
    }

    var foiNegada: Bool {
        status == .denied || status == .restricted
    }

    /// Mostra o pedido do sistema (só aparece se a pessoa ainda não respondeu)
    func pedir() {
        gerenciador.requestWhenInUseAuthorization()
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let novoStatus = manager.authorizationStatus
        Task { @MainActor in
            status = novoStatus
        }
    }
}
