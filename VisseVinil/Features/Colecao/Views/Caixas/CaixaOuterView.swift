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
    
    let helperAnimacao = Namespace()
    
    var body: some View {
        let discos = caixa.discos.filter({!$0.removed})
        let titleSubtitle =
            VStack(alignment: .leading, spacing: 0) {
                Text(caixa.title)
                    .font(.headline)
                    .minimumScaleFactor(0.65)
                    .lineLimit(2)
                Text( "\(discos.count) Disco\(discos.count > 1 ? "s" : "")" )
                    .font(.subheadline)
                    .minimumScaleFactor(0.65)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        let thumb =
        guessThumb(discos.first?.thumbData)
            .resizable().scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 8))
        VStack(spacing: 0) {
            ZStack {
                // Parece meio duvidoso mas funciona
                Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
                VStack(spacing: 0) {
                    if count == 1 {
                        VStack(alignment: .leading) {
                            thumb
                                .matchedGeometryEffect(id: "capaAnimada", in: helperAnimacao.wrappedValue)
                            titleSubtitle
                        }.padding()
                    } else {
                        HStack(alignment: .top) {
                            titleSubtitle
                            Spacer()
                            thumb
                                .matchedGeometryEffect(id: "capaAnimada", in: helperAnimacao.wrappedValue)
                                .containerRelativeFrame([.horizontal], { size, axis in
                                    switch count {
                                    case 2: size * 0.40
                                    case 3: size * 0.25
                                    case 4: size * 0.25
                                    default: size * 0.15
                                    }
                                })
                        }.padding(count > 4 ? 10 : 15)
                    }
                    Spacer()
                }
            }
            caixa.cor.frame(height: count > 4 ? 16 : 24).ignoresSafeArea()
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .shadow(radius: 5)
    }
}

