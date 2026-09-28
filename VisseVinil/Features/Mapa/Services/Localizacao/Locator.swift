//
//  Locator.swift
//  VisseVinil
//
//  Created by Gabriel Alves Gadelha de Melo on 11/09/26.
//

import CoreLocation
import Observation

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
