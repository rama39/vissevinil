//
//  CaixasContainer.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import SwiftUI
import SwiftData

struct tempCaixa: Identifiable {
    var id = UUID()
    var title: String
    var rgba: RGBAColor
    
    
    var cor: Color {
        get { Color(rgba) }
        set { rgba = newValue.toRGBA }
    }
}

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
    
    @State var newCaixa: tempCaixa? = nil
    @State var editandoCaixa: tempCaixa? = nil
    @State var editandoCaixaData: CaixaModel? = nil
    
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
                        Button(role: .destructive) {
                            deleteCaixa(caixa)
                        } label: {
                            Label("Deletar", systemImage: "trash")
                        }
                        Button(role: .confirm) {
                            editandoCaixa = tempCaixa(title: caixa.title, rgba: caixa.rgba)
                            editandoCaixaData = caixa
                        } label: {
                            Label("Editar", systemImage: "pencil")
                        }
                    }
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button { newCaixa = tempCaixa(title: "", rgba: Color.brown.toRGBA) }
                label: { Image(systemName: "plus") }
            }
        }
        .sheet(item: $newCaixa) { _ in
            AddCaixaView(newCaixa: $newCaixa, confirm: {
                if let newCaixa,
                   !newCaixa.title.isEmpty{
                    let newCaixaData = CaixaModel(
                        title: newCaixa.title,
                        rgba: newCaixa.rgba
                    )
                    addCaixa(newCaixa: newCaixaData)
                }
            }, navTitle: "Nova Caixa")
        }
        .sheet(item: $editandoCaixa) { _ in
            AddCaixaView(newCaixa: $editandoCaixa, confirm: {
                if let editandoCaixa,
                   let editada = editandoCaixaData {
                    editada.title = editandoCaixa.title
                    editada.rgba = editandoCaixa.rgba
                }
            }, navTitle: "Editar caixa")
        }
        .alertaGuardar($desRemovendoDisco)
        .searchable(text: $bufferBusca, prompt: "Pesquisar Caixas")
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
