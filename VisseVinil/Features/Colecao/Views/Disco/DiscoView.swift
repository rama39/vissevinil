//
//  DiscoView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 19/09/26.
//

import SwiftUI

struct DiscoView: View {
    
    @Bindable var disco: _DiscoModel
    
    var body: some View {
        VStack {
            frameThumb(disco.thumbData)
            Text("Conteúdo do disco")
        }
        .navigationTitle(disco.title)
        .navigationBarTitleDisplayMode(.automatic)
    }
}
