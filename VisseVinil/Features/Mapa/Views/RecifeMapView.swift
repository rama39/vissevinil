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
class Locator: NSObject, CLLocationManagerDelegate {
    
    //===============================================================================================
    
    //--------------------------------------------------------------------------------------
    // Classe do framework CoreLocation responsável por conversar com o GPS do dispositivo
    private let manager = CLLocationManager()
    // Salva a última localização conhecida
    var currentLocalization: CLLocationCoordinate2D?
    //--------------------------------------------------------------------------------------
    
    //===============================================================================================
    
    //--------------------------------------------------------------------------------------
    // Como Locator herda de NSObject e essa classe já tem um init, precisamos sobrescrever
    override init() {
        // Chama o init original da classe mãe
        super.init()
        // Locator "escuta" CLLocationManager
        manager.delegate = self
    }
    //--------------------------------------------------------------------------------------
    
    //===============================================================================================
    
    //--------------------------------------------------------------------------------------
    // Pedir o acesso à localização do usuário
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        // Liga o GPS e começa a receber atualizações da posição
        manager.startUpdatingLocation()
    }
    //--------------------------------------------------------------------------------------
    
    //===============================================================================================
    /*
     Esse é o método do protocolo CLLocationManagerDelegate, é uma exigência da Apple: pra "escutar
     atualizações de localização. O sistema chama esse método sozinho, automaticamente, toda vez que
     o GPS tem uma posição nova
    */
    //--------------------------------------------------------------------------------------
    // Essa função específica é a exceção, ela pode rodar fora da main thread
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Guarda a localização mais recente do usuário
        guard let lastLocalization = locations.last else { return }
        // Cria uma nova tarefa assíncrona que roda especificamente na main thread, já que
        // currentLocalization precisa ser atualizada na main thread
        Task {
            @MainActor in
            currentLocalization = lastLocalization.coordinate
        }
    }
    //--------------------------------------------------------------------------------------
}

//===================================================================================================
// View Principal do mapa
struct RecifeMapView: View {
    
    // Declaração da lista de Lojas
    @State private var lojas: [Loja] = [
        Loja(nameForSearch: "R Vinil e CDs",
             coordinate: CLLocationCoordinate2D(latitude: -8.03734, longitude: -34.89216),
             ig: nil),
        Loja(nameForSearch: "Vinil Alternativo",
             coordinate: CLLocationCoordinate2D(latitude: -8.06214, longitude: -34.88369),
             ig: nil),
        Loja(nameForSearch: "Pulga Mercado de Discos",
             coordinate: CLLocationCoordinate2D(latitude: -8.03924, longitude: -34.89467),
             ig: nil),
        Loja(nameForSearch: "Taberna do Vinil",
             coordinate: CLLocationCoordinate2D(latitude: -8.03940, longitude: -34.89471),
             ig: nil),
        Loja(nameForSearch: "Bolacha Discos e Coisas",
             coordinate: CLLocationCoordinate2D(latitude: -8.04789, longitude: -34.89889),
             ig: nil),
        Loja(nameForSearch: "Disco de Ouro",
             coordinate: CLLocationCoordinate2D(latitude: -8.06040, longitude: -34.88291),
             ig: nil),
        Loja(nameForSearch: "Blackout Discos",
             coordinate: CLLocationCoordinate2D(latitude: -8.06003, longitude: -34.88234),
             ig: nil),
        Loja(nameForSearch: "Flowers Records Brazil",
             coordinate: CLLocationCoordinate2D(latitude: -8.06222, longitude: -34.88272),
             ig: nil),
        Loja(nameForSearch: "CD & Cia",
             coordinate: CLLocationCoordinate2D(latitude: -8.06209, longitude: -34.88209),
             ig: nil),
        Loja(nameForSearch: "Sebo Pereira",
             coordinate: CLLocationCoordinate2D(latitude: -8.05799, longitude: -34.88632),
             ig: nil),
        Loja(nameForSearch: "Praça do Sebo (Estandes Diversos)",
             coordinate: CLLocationCoordinate2D(latitude: -8.06306, longitude: -34.87872),
             ig: nil),
        Loja(nameForSearch: "Fernando Vinil Discos",
             coordinate: CLLocationCoordinate2D(latitude: -8.04147, longitude: -34.89415),
             ig: nil),
        Loja(nameForSearch: "Sebo da Torre",
             coordinate: CLLocationCoordinate2D(latitude: -8.04526, longitude: -34.90721),
             ig: nil)
    ]
    
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
    private let maximumZoom: CLLocationDistance = 85000
    
    @State private var cameraPosition: MapCameraPosition
    private var locator = Locator()
    
    // Funciona basicamente como um constructor de RecifeMapView
    init() {
        _cameraPosition = State(initialValue: .userLocation(fallback: .region(metropolyRegion)))
    }
    
    //===============================================================================================
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
            // para cada loja cria um symbol no mapa
            ForEach(lojas) { loja in
                Marker(loja.nameForSearch, systemImage: "storefront", coordinate: loja.coordinate)
                    .tint(.blue)
            }

        }
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .onChange(of: locator.currentLocalization) { _, newLocalization in setCameraWith(newLocalization) }
        .onAppear {
            locator.requestLocation() // Solicita a localização do usuário
        }
    }
    
    //===============================================================================================
    private func setCameraWith(_ localization: CLLocationCoordinate2D?) {
        
        // Se a variável estiver vazia, seta como a região inteira e retorna
        guard let localization else {
            cameraPosition = .region(metropolyRegion)
            return
        }
        // Caso contrário, se estiver dentro da região, mostra a localização do usuário
        if metropolyRegion.isIn(localization) {
            cameraPosition = .userLocation(fallback: .region(metropolyRegion))
        } else {
            cameraPosition = .region(metropolyRegion)
        }
    }
    //===============================================================================================
}
//========================================================================================================

#Preview {
    RecifeMapView()
}
