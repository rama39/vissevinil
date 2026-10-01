//
//  CurtidasListView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 01/10/26.
//

import SwiftUI
import SwiftData

struct CurtidasListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var curtidas: [CurtidaModel]
    
    var body: some View {
        List {
            ForEach(curtidas) { curtida in //search filters for master vinyl versions
                NavigationLink {
                    MasterView(master_id: curtida.master_id ?? 0)
                } label: {
                    CurtidaRow(curtida: curtida)
                }
            }
            
            .onDelete(perform: deleteItems)
        }
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let deletado = curtidas[index]
                modelContext.delete(deletado)
            }
        }
    }
}
//
//#Preview {
//    CurtidasListView()
//}
