//
//  AddCaixaView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 24/09/26.
//

import SwiftUI

struct AddCaixaView: View {
    @Binding var newCaixa: tempCaixa?
    let confirm: () -> Void
    let navTitle: String
    var body: some View {
        NavigationStack {
            Form {
                if nil != newCaixa {
                    // Leitura segura: ao salvar/cancelar, newCaixa vira nil enquanto a sheet
                    // ainda está fechando e os campos são lidos de novo (com "!" o app fechava)
                    TextField("Nome da Caixa", text:
                        Binding(
                            get: { newCaixa?.title ?? "" },
                            set: { newCaixa?.title = $0 }
                        )
                    )
                    ColorPicker("Cor da Caixa", selection:
                        Binding(
                            get: { newCaixa?.cor ?? .brown },
                            set: { newCaixa?.rgba = $0.toRGBA }
                        )
                    )
                }
            }
            .navigationTitle(navTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading, content: {
                    Button(role: .cancel) {
                        newCaixa = nil
                    } label: {
                        Image(systemName: "xmark")
                    }
                })
                ToolbarItem(placement: .topBarTrailing, content: {
                    Button(role: .confirm) {
                        confirm()
                        newCaixa = nil
                    } label: {
                        Image(systemName: "checkmark")
                    }
                })
            }
            .presentationDetents([.medium])
        }
    }
}

//#Preview {
//    AddCaixaView()
//}
