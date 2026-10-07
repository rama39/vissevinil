//
//  CurtidaCardView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 01/10/26.
//

import SwiftUI

// MARK: - Card individual de disco

struct CurtidaCardView: View {
    let curtida: CurtidaModel
    var showLocation: Bool = false

    private let cardWidth: CGFloat = 155

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Group {
                if let thumbUrlString = curtida.images?[0].resourceURL, let thumbUrl = URL(string: thumbUrlString) {
                    AsyncImage(url: thumbUrl) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        Color.gray.opacity(0.3)
                    }
                    //.frame(width: 70, height: 70)
                    .cornerRadius(8)
                    .clipped()
                } else { noThumb }
            }
            .frame(
                width: cardWidth,
                height: cardWidth
            )
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 12,
                    style: .continuous
                )
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(curtida.master_title ?? "")
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(curtida.artistsListed)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

//                if showLocation,
//                   let location = curtida.locationName {
//
//                    HStack(spacing: 6) {
//                        Circle()
//                            .fill(
//                                curtida.locationColor
//                                ?? Color(.systemGray3)
//                            )
//                            .frame(width: 8, height: 8)
//
//                        Text(location)
//                            .font(.system(size: 12))
//                            .foregroundStyle(.secondary)
//                            .lineLimit(1)
//                    }
//                    .padding(.top, 2)
//                }
            }
        }
        .frame(
            width: cardWidth,
            alignment: .leading
        )
    }
}
