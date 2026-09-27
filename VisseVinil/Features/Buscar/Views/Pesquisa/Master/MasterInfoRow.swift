//
//  InfoRow.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 11/09/26.
//

import SwiftUI

struct MasterInfoRow: View {
    let title: String
    let value: String?
    
    var body: some View {
        if let value = value, !value.isEmpty {
            HStack {
                Text(title)
                    .bold()
                Spacer()
                Text(value)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.trailing)
            }
        }
    }
}
