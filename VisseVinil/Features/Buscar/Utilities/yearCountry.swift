//
//  yearCountry.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 26/09/26.
//

extension DiscogsRelease {
    var yearCountry: String {
        if let year = self.year,
           let country = self.country,
           country != "Unknown" {
            year + " - " + country
        } else if let year = self.year {
            year
        } else if let country = self.country,
                  country != "Unknown" {
            country
        } else { "Desconhecido" }
    }
}
