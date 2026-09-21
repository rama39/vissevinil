//
//  MKCoordinateRegionExtension.swift
//  VisseVinil
//
//  Created by Gabriel Alves Gadelha de Melo on 21/09/26.
//

import MapKit

// Vou adicionar algo novo a um tipo que já existe, todo MKCoordinateRegion ganha esse método
//=======================================================================================================

extension MKCoordinateRegion {
    
    // retorna true ou false a depender se certa coordenada está ou não em certa região
    func isIn(_ coordinate: CLLocationCoordinate2D) -> Bool {
        /*
          Se uma região tem centro X e tamanho de 4 un. Podemos definí-la como [X + 2, X - 2],
          basicamente, fazemos isso com a latitude e longitude para achar a região desejada
        */
        let latMin: Double = center.latitude - span.latitudeDelta / 2
        let latMax: Double = center.latitude + span.latitudeDelta / 2
        let lonMin: Double = center.longitude - span.longitudeDelta / 2
        let lonMax: Double = center.longitude + span.longitudeDelta / 2
        // Verifica se a coordenada entá dentro da região em latitude e longitude
        let latIsIn: Bool = coordinate.latitude >= latMin && coordinate.latitude <= latMax
        let lonIsIn: Bool = coordinate.longitude >= lonMin && coordinate.longitude <= lonMax
        
        return  latIsIn && lonIsIn
    }
}

//=======================================================================================================

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}

//=======================================================================================================
