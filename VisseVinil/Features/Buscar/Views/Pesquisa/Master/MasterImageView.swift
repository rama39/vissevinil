//
//  MasterImageView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 17/09/26.
//

import SwiftUI

struct MasterImageView: View {
    let images: [MasterImage]?
    var body: some View {
        if  let images, images.count > 0,
            let thumbUrl = images[0].resourceURL,
            let url = URL(string: thumbUrl) {
            AsyncImage(url: url) { image in
                image
                    .resizable()
                    .scaledToFit()
            } placeholder: {
                ProgressView()
            }
            .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            Image(systemName: "play.square")
                .resizable()
                .scaledToFit()
                .foregroundColor(.gray)
        }
    }
}
