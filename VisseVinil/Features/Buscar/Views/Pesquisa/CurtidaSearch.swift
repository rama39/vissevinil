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
    
    let id: Int
    
    var body: some View {
        let curtida = curtidas.first(where: {$0.master_id == id})
        if curtida != nil {
            Image(systemName: "heart.fill")
                .foregroundStyle(.primary)
                //.foregroundStyle(.vinho)
                //.shadow(color: .primary, radius: 1)
        }
    }
}
