//
//  AdicionadoDiscoOuterView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 17/09/26.
//

import SwiftUI

struct AdicionadoDiscoOuterView: View {
    @State var version: MasterVersionVersion
    var body: some View {
        HStack {
            if  let thumbUrl = version.thumb,
                let url = URL(string: thumbUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                } placeholder: {
                    ProgressView()
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                Image(systemName: "music.note")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.gray)
            }
            VStack {
                Text(version.title ?? "")
                Text("\(version.country ?? "")")
            }
        }
    }
}

