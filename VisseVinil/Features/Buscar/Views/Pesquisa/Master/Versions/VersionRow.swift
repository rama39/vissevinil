//
//  AdicionadoDiscoOuterView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 17/09/26.
//

import SwiftUI

struct VersionRow: View {
    @State var master: MasterResponse
    @State var version: MasterVersion
    var body: some View {
        HStack {
            AddVersionView(master: master, version: version)
            frameThumb(version.thumbData)
            VStack(alignment: .leading) {
                Text(version.title ?? "")
                Text("\(version.country ?? "?"), \(version.released ?? "?")")
            }
            Spacer()
        }
    }
}

