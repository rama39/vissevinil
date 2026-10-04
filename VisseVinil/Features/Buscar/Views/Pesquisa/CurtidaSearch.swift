//
//  CurtidaSearch.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/10/26.
//

import SwiftUI
import SwiftData

struct CurtidaSearch: View {
    
    @Query private var curtidas: [CurtidaModel]
    
    let release: DiscogsRelease
    
    var body: some View {
        let curtida = curtidas.first(where: {$0.master_id == release.id})
        Image(systemName: "heart" + (curtida != nil ? ".fill" : ""))
    }
}
