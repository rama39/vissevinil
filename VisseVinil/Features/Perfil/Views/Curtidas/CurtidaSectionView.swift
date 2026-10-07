//
//  RecordSectionView.swift
//  VisseVinil
//
//  Created by Rian Antony Medeiros de Abreu on 01/10/26.
//

import SwiftUI

struct CurtidaSectionView: View {
    let title: String
    let records: [CurtidaModel]
    var showLocation: Bool = false
    var onSeeAllTapped: () -> Void = {}
    var onRecordTapped: (CurtidaModel) -> Void = { _ in }

    // Quantidade máxima de discos exibidos na prévia.
    private let previewLimit = 8

    // Os 8 discos que estão sendo exibidos atualmente.
    @State private var visibleRecords: [CurtidaModel] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // MARK: - Título da seção

            Button(action: onSeeAllTapped) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)

                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)

            // MARK: - Lista horizontal

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {

                    ForEach(visibleRecords, id: \.id) { record in
                        CurtidaCardView (
                            curtida: record,
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

