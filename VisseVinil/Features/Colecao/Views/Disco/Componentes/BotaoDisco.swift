//
//  BotaoDisco.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 30/09/26.
//

import SwiftUI

struct BotaoDisco: View {
    let action: () -> Void
    let image: String
    let fill: Bool
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: image + (fill ? ".fill" : ""))
                .resizable().scaledToFit()
                .frame(width:25, height: 25)
        }
        .buttonStyle(.plain)
    }
}
