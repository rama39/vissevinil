//
//  BotaoCurtidaMaster.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 01/10/26.
//

import SwiftUI
import SwiftData

struct BotaoCurtidaDisco: View {
    @Environment(\.modelContext) private var modelContext
    func save() { if modelContext.hasChanges { try? modelContext.save() } }
    @Query private var curtidas: [CurtidaModel]
    @Query private var desejados: [WishlistModel]
    
    let disco: DiscoModel
    
    var body: some View {
        let curtida = curtidas.first(where: {$0.master_id == disco.master_id})
        BotaoDisco( action: {
            if curtida == nil {
                saveCurtida(disco: disco)
            } else {
                deleteCurtida(curtida: curtida!)
            }
        }, image: "heart", fill: curtida != nil)
    }
    
    func saveCurtida(disco: DiscoModel) {
        withAnimation {
            let newCurtida = CurtidaModel(disco: disco)
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
