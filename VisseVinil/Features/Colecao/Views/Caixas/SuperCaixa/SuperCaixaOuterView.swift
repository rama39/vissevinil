//
//  SuperCaixaOuterView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 05/10/26.
//

import SwiftUI
import SwiftData

struct SuperCaixaOuterView: View {
    
    @Query private var discos: [DiscoModel]
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Color(uiColor: .secondarySystemBackground).ignoresSafeArea()
                
                Image("Discos Todos")
                    .resizable().scaledToFit()
                
                VStack(spacing: 0) {
                        HStack(alignment: .top) {
                            
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Todos os Discos")
                                    .font(.title3).bold()
                                    .lineLimit(2)
                                Text( "\(discos.count)" )
                                    .font(.largeTitle).bold()
                                    .lineLimit(2)
                            }
                            Spacer()
//                                .containerRelativeFrame([.horizontal], { size, axis in
//                                    size * 0.25
//                                })
                        }.padding( 15)
                    Spacer()
                }
            }
            //caixa.cor.frame(height: count > 4 ? 16 : 24).ignoresSafeArea()
        }
        .frame(height: 120)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal).padding(.vertical, 5)
        .shadow(radius: 5)
    }
}

#Preview {
    SuperCaixaOuterView()
}
