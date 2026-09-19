//
//  AddButtonView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 19/09/26.
//

import SwiftUI
import SwiftData

struct AddVersionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var discos: [_DiscoModel]
    
    @State var master: MasterResponse
    @State var version: MasterVersion
    
    var body: some View {
        let saved = discos.map{$0.id}.contains(version.id)
        Button {
            if saved {
                delete()
            } else {
                save()
            }
        } label: {
            Image(systemName: "plus.circle" + (saved ? ".fill" : ""))
        }
    }
    
    private func getDiscoModel() -> _DiscoModel { _DiscoModel(
            title: version.title ?? "",
            artists: master.artists?.map{$0.name ?? ""} ?? [],
            year: version.released ?? "",
            country: version.country ?? "",
            genres: master.genres ?? [],
            styles: master.styles ?? [],
            thumbData: version.thumbData,
            id: version.id ?? 0,
            posicao: discos.count
        )
    }
    
    private func save() {
        withAnimation {
            let newDisco = getDiscoModel()
            modelContext.insert(newDisco)
            let newEvento = EventoModel(.adicionou)
            newEvento.disco = newDisco
            modelContext.insert(newEvento)
        }
    }

    private func delete() {
        withAnimation {
            let deletedDisco = getDiscoModel()
            modelContext.delete(deletedDisco)
        }
    }
}

