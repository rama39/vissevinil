//
//  MasterIsSavedView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 27/09/26.
//

import SwiftUI
import SwiftData

struct MasterIsSavedView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var discos: [DiscoModel]
    
    let master_id: Int
    
    var body: some View {
        let savedAs = discos.filter({$0.master_id == master_id})
        if savedAs.count > 0 {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(savedAs) { version in
                        NavigationLink {
                            DiscoView(disco: version)
                        } label: {
                            if let caixa = version.caixa {
                                CaixaTag(caixa: caixa).padding(.trailing)
                            } else {
                                Text(version.title).padding(.trailing)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}
