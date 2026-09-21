//
//  AddButtonView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 19/09/26.
//

import SwiftUI
import SwiftData

struct AddVersionView: View {
    
    let master: MasterResponse
    let version: MasterVersion
    
    let action: ()->Void
    let saved: Bool
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "plus.circle" + (saved ? ".fill" : ""))
        }
        .buttonStyle(.borderless)
    }
    
}

