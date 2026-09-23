//
//  LojaModel.swift
//  VisseVinil
//
//  Created by Gabriel Alves Gadelha de Melo on 17/09/26.
//

import Foundation
import SwiftData
import CoreLocation
import ClusterMap

/**
//===========================================================================
 Model Loja: Nome, Coordenadas, Categoria, Endereço, Telefone, Site, Instagram, ÚltimaAtualização.
//===========================================================================
 **/
//==================================================================================

@Model
class Loja {
    
    //=======================================================================
    
    //-------------------------------------------------------------------
    // Variáveis utilizadas para pesquisa e precisa de cadastro prévio
    var nameForSearch: String
    var latitude: Double
    var longitude: Double
    //-------------------------------------------------------------------
    // Variáveis que são pesquisas e adquiridas via MapKit
    var officialName: String?
    var category: String?
    var address: String?
    var fone: String?
    var website: String?
    //-------------------------------------------------------------------
    // Variáveis que precisa cadastro ou são atualizadas pelo sistema
    var lastUpdate: Date?
    var ig: String?
    //-------------------------------------------------------------------
    
    //=======================================================================
    // Inicialização: salva o nome, coordenadas e o instagram (opcional)
    
    init(nameForSearch: String, coordinate: CLLocationCoordinate2D, ig: String? = nil) {
        self.nameForSearch = nameForSearch
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.ig = ig
    }
    
    // Tradução de Latitude e longitude para CLLocationCoordinate2D
    var coordinate: CLLocationCoordinate2D {
        get { CLLocationCoordinate2D(latitude: latitude, longitude: longitude) }
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    
    //=======================================================================
}

//=====================================================================================
// A extension só declara a conformidade, a propriedade já existe acima
extension Loja: CoordinateIdentifiable {}

//=====================================================================================

/*
 -----------------------------------------------------------------------------------
 Permite Loja ser usada como ClusterManager<Loja>, a biblioteca exige que qualquer
 tipo que ela gerencia tenha uma propriedade coordinate com get/set
 -----------------------------------------------------------------------------------
 Hashable -> esse tipo sabe se transformar num número (hash) que representa sua
 identidade, e sabe comparar se dois valores são iguais
 -----------------------------------------------------------------------------------
*/
extension Loja: Hashable {
    // Implementa a funcionalidade de Equatable, exigida de baixo dos panos
    static func == (lhs: Loja, rhs: Loja) -> Bool {
        // ("comparar se são iguais")
        lhs.persistentModelID == rhs.persistentModelID
    }
    // "virar um número resumido"
    func hash(into hasher: inout Hasher) {
        hasher.combine(persistentModelID)
    }
}

//=====================================================================================

extension Loja: @unchecked Sendable {}

//=====================================================================================
