//
//  LojaModel.swift
//  VisseVinil
//
//  Created by Gabriel Alves Gadelha de Melo on 17/09/26.
//

import Foundation
import SwiftData
import CoreLocation

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
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    //=======================================================================
}

//==================================================================================
