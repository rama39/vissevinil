//
//  BotaoCurtida.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 01/10/26.
//

import SwiftUI
import SwiftData

struct BotaoCurtidaMaster: View {
    @Environment(\.modelContext) private var modelContext
    func save() { if modelContext.hasChanges { try? modelContext.save() } }
    @Query private var curtidas: [CurtidaModel]
    @Query private var desejados: [WishlistModel]
    
    let master: MasterResponse
    
    var body: some View {
        let curtida = curtidas.first(where: {$0.master_id == master.id})
        BotaoDisco( action: {
            if curtida == nil {
                saveCurtida(master: master)
            } else {
                deleteCurtida(curtida: curtida!)
            }
        }, image: "heart", fill: curtida != nil)
    }
    
    func saveCurtida(master: MasterResponse) {
        withAnimation {
            let newCurtida = CurtidaModel(master: master)
            modelContext.insert(newCurtida)
            save()
        }
    }

    func deleteCurtida(curtida: CurtidaModel) {
        withAnimation {
            let deletedCurtida = curtida
            modelContext.delete(deletedCurtida)
            save()
        }
    }
}
