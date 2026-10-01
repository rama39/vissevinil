//
//  TelaGenericaView.swift
//  VisseVinil
//
//  Created by Pedro Augusto Santos de Sousa on 30/09/26.
//

import SwiftUI

struct TelaGenericaView: View {
    let texto: String

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            Text(texto)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.primary)
        }
        .navigationTitle(texto)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TelaGenericaView(texto: "Wishlist")
    }
}
