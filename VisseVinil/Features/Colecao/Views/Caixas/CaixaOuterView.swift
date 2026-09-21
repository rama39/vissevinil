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
        ZStack {
            VStack {
                Color.white
                caixa.cor.frame(height: 20)
            }.clipShape(RoundedRectangle(cornerRadius: 8))
            if count == 1 {
                VStack {
                    if let topo = caixa.discos.first {
                        guessThumb(topo.thumbData)
                            .resizable().scaledToFit()
                            .padding()
                    } else {
                        Image("square")
                            .padding()
                    }
                    VStack {
                        Text(caixa.title)
                        Text(
                            "\(caixa.discos.count) Disco\(caixa.discos.count > 1 ? "s" : "")"
                        )
                    }
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
                            .padding()
                    } else {
                        Image("square")
                            .padding()
                    }
                }
            }
        }
    }
}

