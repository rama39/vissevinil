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
        let titleSubtitle =
            VStack(alignment: .leading, spacing: 0) {
                Text(caixa.title)
                    .font(.headline)
                Text( "\(caixa.discos.count) Disco\(caixa.discos.count > 1 ? "s" : "")" )
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        let thumb =
        guessThumb(caixa.discos.first?.thumbData)
            .resizable().scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 8))
        VStack(spacing: 0) {
            ZStack {
                // Parece meio duvidoso mas funciona
                Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
                if count == 1 {
                    VStack(alignment: .leading) {
                        thumb
                        titleSubtitle
                    }.padding()
                } else {
                    HStack(alignment: .top) {
                        titleSubtitle
                        Spacer()
                        thumb
                            .containerRelativeFrame([.horizontal], { size, axis in
                                switch count {
                                case 2: size * 0.40
                                case 3: size * 0.25
                                default: size * 0.20
                                }
                            })
                    }.padding(15)
                }
            }
            caixa.cor.frame(height: 20).ignoresSafeArea()
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(radius: 5)
    }
}

