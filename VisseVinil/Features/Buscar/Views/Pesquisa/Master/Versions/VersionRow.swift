//
//  AdicionadoDiscoOuterView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 17/09/26.
//

import SwiftUI

struct VersionRow: View {
    
    let master: MasterResponse
    let version: MasterVersion
    
    let action: ()->Void
    let saved: Bool
    
    var body: some View {
        HStack {
            AddVersionView(master: master, version: version, action: action, saved: saved)
            frameThumb(version.thumbData)
            VStack(alignment: .leading) {
                Text(version.title ?? "")
                Text("\(version.country ?? "?"), \(version.released ?? "?")")
            }
            Spacer()
        }
    }
}

