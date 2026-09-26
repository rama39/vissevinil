//
//  CaixasContainer.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import SwiftUI
import SwiftData

struct CaixasGridView: View {
    @Environment(\.modelContext) private var modelContext
    func save() { if modelContext.hasChanges { try? modelContext.save() } }
    @Query private var caixas: [CaixaModel]
    
    @State private var bufferBusca = ""
    var caixasBuscadas: [CaixaModel] {
        caixas
        .filter { caixa in
            bufferBusca.isEmpty ||
            caixa.title.localizedCaseInsensitiveContains(bufferBusca)
        }
//        .sorted(by: {
//            $0.posicao > $1.posicao
//        })
//        .filter({!$0.removed})
    }
    
    @State var newCaixa: CaixaModel? = nil
    
    @State var desRemovendoDisco: DiscoModel? = nil
    
    var body: some View {
        let columns = caixas.count > 4 ?
            [GridItem(.flexible()), GridItem(.flexible())] :
            [GridItem(.flexible())]
        ScrollView {
            if desRemovendoDisco != nil {
                ZStack {
                    Color(uiColor: .secondarySystemBackground).ignoresSafeArea().clipShape(RoundedRectangle(cornerRadius: 8))
                    DiscosRemovidosView(desRemovendoDisco: $desRemovendoDisco)
                        .padding()
                }
                .padding(.horizontal)
            }
            LazyVGrid(columns: columns) {
                ForEach(caixasBuscadas) { caixa in
                    NavigationLink {
                        CaixaView(caixa: caixa)
                    } label: {
                        CaixaOuterView(caixa: caixa, count: caixas.count)
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button {
                            deleteCaixa(caixa)
                        } label: {
                            Label("Deletar", systemImage: "trash")
                        }
                    }
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { newCaixa = CaixaModel(title: "", rgba: Color.brown.toRGBA) }
                label: { Image(systemName: "plus") }
            }
        }
        .sheet(item: $newCaixa) { _ in
            AddCaixaView(newCaixa: $newCaixa, addCaixa: {
                if let newCaixa,
                   !newCaixa.title.isEmpty{
                    addCaixa(newCaixa: newCaixa)
                }
            })
        }
        .alertaGuardar($desRemovendoDisco)
        .searchable(text: $bufferBusca)
    }
    
    private func addCaixa(newCaixa: CaixaModel) {
        withAnimation {
            let newCaixa = newCaixa
            modelContext.insert(newCaixa)
            save()
        }
    }
    
    private func deleteCaixa(_ caixa: CaixaModel) {
        withAnimation {
            let deletedCaixa = caixa
//            let pos = deletedDisco.posicao
//            for i in discos.indices {
//                if discos[i].posicao > pos {
//                    discos[i].posicao -= 1
//                }
//            }
            modelContext.delete(deletedCaixa)
            save()
        }
    }
}

#Preview {
    CaixasGridView()
        .modelContainer(for: appSchema, inMemory: true)
}
