//
//  RemoveDiscoButton.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 28/09/26.
//

import SwiftUI

struct RemoveDiscoButton: View {
    let action: () -> Void
    var body: some View {
        Button() {
            withAnimation {
                action()
            }
        } label: {
            HStack {
                Image(systemName: "tray.and.arrow.up")
                Spacer()
                Text("Pegar Disco")
                Spacer()
            }
            .padding()
            .background {Color.green.opacity(0.25)}
            .clipShape(RoundedRectangle(cornerRadius: 100))
            .foregroundStyle(.green)
        }
        .buttonStyle(.plain)
        .padding(.top)
    }
}

