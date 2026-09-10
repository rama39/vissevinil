//
//  MapaView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import SwiftUI
import SwiftData
import MapKit

@MainActor
@Observable
class Localizador: NSObject {
    // Gerencia acesso à localização
    private let manager = CLLocationManager()
    // Pede localização
    func pedirPermissao() {
        manager.requestWhenInUseAuthorization()
    }
}

// clica Show Quick Help no MapaView
/**
 OOh mah gah
 */
struct MapaView: View {
    @State private var posicaoInicial: MapCameraPosition =
        .userLocation(fallback: .automatic)
    
    private var localizador = Localizador()
    
    var body: some View {
        Map(position: $posicaoInicial) {
            UserAnnotation()
        }
        // mapa esconde icones dos outros locais
        .mapStyle( .standard (
            pointsOfInterest: [],
            showsTraffic: false
        ) )
        // permite alinhar ao Norte ou Usuario
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        // pede por favor
        .onAppear {
            localizador.pedirPermissao()
        }
    }
}

#Preview {
    MapaView()
        .modelContainer(for: appSchema, inMemory: true)
}
