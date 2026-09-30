//
//  RecordSectionView.swift
//  VisseVinil
//
//  Created by Pedro Augusto Santos de Sousa on 16/09/26.
//

import SwiftUI

struct RecordSectionView: View {
    let title: String
    let records: [DiscoModel]
    var showLocation: Bool = false
    var onSeeAllTapped: () -> Void = {}
    var onRecordTapped: (DiscoModel) -> Void = { _ in }

    // Quantidade máxima de discos exibidos na prévia.
    private let previewLimit = 8

    // Os 8 discos que estão sendo exibidos atualmente.
    @State private var visibleRecords: [DiscoModel] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // MARK: - Título da seção

            Button(action: onSeeAllTapped) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(.primary)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.primary)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)

            // MARK: - Lista horizontal

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {

                    ForEach(visibleRecords, id: \.id) { record in
                        RecordCardView(
                            record: record,
                            showLocation: showLocation
                        )
                        .onTapGesture {
                            onRecordTapped(record)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .onAppear {
            carregarDiscosAleatorios()
        }
    }

    // MARK: - Seleção aleatória

    private func carregarDiscosAleatorios() {
        guard !records.isEmpty else {
            visibleRecords = []
            return
        }

        visibleRecords = Array(
            records.shuffled().prefix(previewLimit)
        )
    }
}

// MARK: - Card individual de disco

struct RecordCardView: View {
    let record: DiscoModel
    var showLocation: Bool = false

    private let cardWidth: CGFloat = 155

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Group {
                if let coverImage = record.coverImage {
                    coverImage
                        .resizable()
                        .scaledToFill()
                } else {
                    ZStack {
                        Color(.systemGray5)

                        Image(systemName: "opticaldisc")
                            .foregroundStyle(.secondary)
                    }
                }
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
                Text(record.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(record.artistsListed)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                if showLocation,
                   let location = record.locationName {

                    HStack(spacing: 6) {
                        Circle()
                            .fill(
                                record.locationColor
                                ?? Color(.systemGray3)
                            )
                            .frame(width: 8, height: 8)

                        Text(location)
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .padding(.top, 2)
                }
            }
        }
        .frame(
            width: cardWidth,
            alignment: .leading
        )
    }
}

#Preview {
    let disco1 = DiscoModel(
        master_title: "Igor",
        artists: [
            MasterArtist(
                join: nil,
                name: "Tyler, The Creator",
                anv: nil,
                tracks: nil,
                role: nil,
                resourceURL: nil,
                id: nil
            )
        ],
        master_id: nil,
        title: "Igor",
        id: 0,
        posicao: 0
    )

    let disco2 = DiscoModel(
        master_title: "Igor",
        artists: [
            MasterArtist(
                join: nil,
                name: "Tyler, The Creator",
                anv: nil,
                tracks: nil,
                role: nil,
                resourceURL: nil,
                id: nil
            )
        ],
        master_id: nil,
        title: "Igor",
        id: 1,
        posicao: 1
    )

    let caixa1 = CaixaModel(
        title: "Estante sala",
        rgba: RGBAColor(
            r: 244,
            g: 154,
            b: 194,
            a: 255
        )
    )

    let caixa2 = CaixaModel(
        title: "Caixa casa de Gabriel",
        rgba: RGBAColor(
            r: 52,
            g: 199,
            b: 89,
            a: 255
        )
    )

    disco1.caixa = caixa1
    disco2.caixa = caixa2

    return RecordSectionView(
        title: "Meus Discos",
        records: [
            disco1,
            disco2
        ],
        showLocation: true
    )
    .background(
        Color(.systemGroupedBackground)
    )
}
