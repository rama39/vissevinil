//
//  DiscosRemovidosView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 25/09/26.
//

import SwiftUI
import SwiftData

struct DiscosRemovidosView: View {
    @Environment(\.modelContext) private var modelContext
    func save() { if modelContext.hasChanges { try? modelContext.save() } }
    @Query private var discos: [DiscoModel]
    
    @Binding var desRemovendoDisco: DiscoModel?
    
    var body: some View {
        let discosRemovidos = discos.filter({$0.removed})
        if !discosRemovidos.isEmpty {
            TabView {
                ForEach(discosRemovidos) { disco in
                    HStack {
                        guessThumb(disco.thumbData)
                            .resizable().scaledToFit().frame(width: 70, height: 70)
                            .clipShape(RoundedRectangle(cornerRadius: 1))
                        VStack(alignment: .leading) {
                            Text("Disco removido da caixa")
                                .font(.headline)
                            Text(disco.title)
                            Text(disco.artistsListed).font(.subheadline).foregroundStyle(.secondary)
                        }
                        Spacer()
                        Button(role: .confirm) {
                            desRemovendoDisco = disco
                        } label: {
                            Image(systemName: "tray.and.arrow.down")
                                .resizable().scaledToFit().frame(width: 30)
                        }
                    }.padding(.horizontal, 4)
                }
            }
            .tabViewStyle(.page)
            .frame(height: 78)
        }
    }
}

//#Preview {
//    let container = ModelContainer (
//        for: appSchema,
//        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
//    )
//
//    let sampleDiscos = [
//        DiscoModel(master_title: "Master of Puppets", master_id: 1000, id: 1000, posicao: 0),
//        DiscoModel(master_title: "Ride the Lightning", master_id: 500, id: 500, posicao: 1),
//        DiscoModel(master_title: "Kill em All", master_id: 1500, id: 1500, posicao: 2)
//    ]
////    sampleDiscos.forEach {
////        container.mainContext.insert($0)
////    }
//
//    return DiscosRemovidosView()
//        .modelContainer(container)
//}
