//
//  RecifeMapView.swift
//  VisseVinil
//
//  Created by Gabriel Alves Gadelha de Melo on 11/09/26.
//

import SwiftUI
import MapKit

/*
===============================================================================================
 - Struct x Class -> classes, quando chamadas em outra parte do código, é utilizada a mesma
instância, sem criar cópias;
- Ao utilizar o CLLocationManeger, precisamos que o código tbm aceite as regras antigas da
Apple, por isso o NSObject;
===============================================================================================
*/

/**
 =================================================================================
 "Locator é uma caixa (class) que fala o idioma antigo da Apple pra poder conversar com o GPS (NSObject), é transparente para o
 SwiftUI perceber mudanças (@Observable), e só pode ser mexida na thread principal por segurança (@MainActor)"
 =================================================================================
 **/
@MainActor
@Observable
class Locator: NSObject {
    // classe do framework CoreLocation responsável por conversar com o GPS do dispositivo
    private let maneger = CLLocationManager()
    
    //===============================================================================================
    // Pedir o acesso à localização do usuário
    
    func requestLocation() {
        maneger.requestWhenInUseAuthorization()
    }
    //===============================================================================================
}

// View Principal do mapa
struct RecifeMapView: View {
    
    /*
    ===============================================================================================
     Imagine que existe uma câmera em cima do globo, precisamos definir duas coisas:
        - Onde ela está posicionada;
        - A que altura ela está.
     
     Dessa forma, como queremos limitar apenas Recife, devemos "prender" o usuário nessa posição.
    ===============================================================================================
    */
    
    /**
     =================================================================================
     "Eu declaro que vou ter uma posição de câmera (cameraPosition), mas só decido qual vai ser o valor inicial dela
     quando a View for realmente criada (init), porque esse valor depende da variável rmretropolyRegion. E o valor
     escolhido é: 'segue o usuário se possível, senão mostra a cidade inteira'."
     =================================================================================
     */
    private let metropolyRegion = MKCoordinateRegion (
        center: CLLocationCoordinate2D(latitude: -8.0576, longitude: -34.9050),
        span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.20)
    )
    
    // Limitantes do Zoom
    private let minimumZoom: CLLocationDistance = 500
    private let maximumZoom: CLLocationDistance = 140000
    
    @State private var cameraPosition: MapCameraPosition
    private var locator = Locator()
    
    // Funciona basicamente como um constructor de RecifeMapView
    init() {
        _cameraPosition = State(initialValue: .userLocation(fallback: .region(metropolyRegion)))
    }
    
    /**
     =================================================================================
     Faz o mapa mostrar a "Principal" Região Metropolitana do Recife  e "prende" o usuário nela.
     =================================================================================
     **/
    var body: some View {
        
        // Cria o mapa com as bordas limitantes
        Map(
            position: $cameraPosition,
            bounds: MapCameraBounds(
                centerCoordinateBounds: metropolyRegion,
                minimumDistance: minimumZoom,
                maximumDistance: maximumZoom
            )
        ) {
            UserAnnotation() // Exibe o usuário no mapa
        }
        .onAppear {
            locator.requestLocation() // Solicita a localização do usuário
        }
    }
}

#Preview {
    RecifeMapView()
}
