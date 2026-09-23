//
//  CaixaOuterView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 03/09/26.
//

import SwiftUI

struct CaixaOuterView: View {
    
    @Bindable var caixa: CaixaModel
    let count: Int
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color.white.ignoresSafeArea()
                if count == 1 {
                    VStack {
                        if let topo = caixa.discos.first {
                            guessThumb(topo.thumbData)
                                .resizable().scaledToFit()
                                .padding(0)
                        } else {
                            Image(systemName: "square")
                                .resizable().scaledToFit()
                                .padding(0)
                        }
                        VStack(spacing: 0) {
                            Text(caixa.title).padding(0)
                            Text(
                                "\(caixa.discos.count) Disco\(caixa.discos.count > 1 ? "s" : "")"
                            ).padding(0)
                        }.padding(0)
                    }
                } else {
                    HStack {
                        VStack {
                            Text(caixa.title)
                            Text(
                                "\(caixa.discos.count) Disco\(caixa.discos.count > 1 ? "s" : "")"
                            )
                        }
                        if let topo = caixa.discos.first {
                            frameThumb(topo.thumbData)
                                .padding(0)
                        } else {
                            Image(systemName: "square")
                                .resizable().scaledToFit()
                                .padding(0)
                        }
                    }
                }
            }
            caixa.cor.frame(height: 20).ignoresSafeArea()
        }.clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

