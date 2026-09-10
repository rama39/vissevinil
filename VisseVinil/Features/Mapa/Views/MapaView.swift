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


struct Local: Identifiable {
    let id = UUID()
    let nome: String
    var favorito: Bool = false
    let coordenadas: CLLocationCoordinate2D
    init(nome: String, coordenadas: CLLocationCoordinate2D) {
        self.nome = nome
        self.coordenadas = coordenadas
    }
    init(nome: String, _ latitude: Double, _ longitude: Double) {
        self.init(
            nome: nome,
            coordenadas: CLLocationCoordinate2D(
                latitude: latitude,
                longitude: longitude
            )
        )
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
    
    @State var testeLocais = [
        Local ( nome: "Apple Park Visitor Center", 37.3328, -122.0053 ),
        Local ( nome: "The Ring (Prédio Principal)", 37.3347, -122.0089 ),
        Local ( nome: "Steve Jobs Theater", 37.3308, -122.0117 )
    ]
    
    var body: some View {
        Map(position: $posicaoInicial) {
            UserAnnotation()
            
            ForEach($testeLocais) { $local in
                Marker (
                    local.nome,
                    systemImage: local.favorito ? "star" : "house",
                    coordinate: local.coordenadas
                )
                .tint(.blue)
             }
        }
        // mapa esconde icones dos outros locais
        .mapStyle( .standard (
            pointsOfInterest: .excludingAll,
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
