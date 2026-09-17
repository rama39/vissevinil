//
//  DiscosFavCarrossel.swift
//  VisseVinil
//

import SwiftUI
import Combine

struct DiscosFavCarrossel: View {
    let records: [DiscoModel]

    /// Intervalo entre trocas automáticas de destaque.
    var autoAdvanceInterval: TimeInterval = 3.0

    /// Ângulo máximo de rotação (em graus) para os cards mais afastados do centro.
    private let maxRotationDegrees: Double = 55
    /// Quanto o card encolhe ao se afastar do centro (0 = não encolhe, 1 = desaparece).
    private let maxScaleReduction: CGFloat = 0.32
    /// Quanto o card fica translúcido ao se afastar do centro.
    private let maxOpacityReduction: Double = 0.55

    private let featuredWidth: CGFloat = 200
    private let featuredHeight: CGFloat = 200
    private let coordinateSpaceName = "favoriteCarousel"

    @State private var selectedIndex: Int = 0
    @State private var scrollPosition: Int?
    private let timer = Timer.publish(every: 3.0, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 14) {
            GeometryReader { outerGeo in
                let containerWidth = outerGeo.size.width

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 36) {
                        ForEach(Array(records.enumerated()), id: \.element.id) { index, record in
                            GeometryReader { itemGeo in
                                let midX = itemGeo.frame(in: .named(coordinateSpaceName)).midX
                                // progress: 0 = card centralizado; 1 (ou -1) = a uma "largura de container" de distância.
                                let progress = Double((midX - containerWidth / 2) / containerWidth)
                                let clampedProgress = min(max(progress, -1), 1)

                                FavoriteRecordCard(record: record, width: featuredWidth, height: featuredHeight)
                                    .scaleEffect(1 - abs(clampedProgress) * maxScaleReduction)
                                    .opacity(1 - abs(clampedProgress) * maxOpacityReduction)
                                    .rotation3DEffect(
                                        .degrees(clampedProgress * -maxRotationDegrees),
                                        axis: (x: 0, y: 1, z: 0),
                                        anchor: clampedProgress >= 0 ? .leading : .trailing,
                                        perspective: 0.6
                                    )
                                    // O card mais perto do centro fica por cima dos vizinhos.
                                    .zIndex(1 - abs(clampedProgress))
                            }
                            .frame(width: featuredWidth, height: featuredHeight)
                            .id(index)
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.horizontal, (containerWidth - featuredWidth) / 2)
                }
                .coordinateSpace(name: coordinateSpaceName)
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: $scrollPosition)
                .onChange(of: scrollPosition) { _, newValue in
                    if let newValue { selectedIndex = newValue }
                }
            }
            // Um pouco mais de altura pra sobrar espaço vertical durante a rotação 3D.
            .frame(height: featuredHeight + 24)

            // Título e artista do disco em destaque no momento.
            if records.indices.contains(selectedIndex) {
                VStack(spacing: 2) {
                    Text(records[selectedIndex].title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.85))
                        .lineLimit(1)
                    Text(records[selectedIndex].artist)
                        .font(.system(size: 14))
                        .foregroundStyle(Color(red: 0.45, green: 0.45, blue: 0.45))
                        .lineLimit(1)
                }
                .id(selectedIndex)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.25), value: selectedIndex)
            }

            // Indicadores de página (bolinhas).
            HStack(spacing: 6) {
                ForEach(records.indices, id: \.self) { index in
                    Circle()
                        .fill(index == selectedIndex ? Color.black.opacity(0.75) : Color.gray.opacity(0.35))
                        .frame(width: 6, height: 6)
                        .animation(.easeInOut(duration: 0.25), value: selectedIndex)
                }
            }
        }
        .onReceive(timer) { _ in
            advanceToNext()
        }
        .onAppear {
            scrollPosition = 0
        }
    }

    private func advanceToNext() {
        guard !records.isEmpty else { return }
        let next = (selectedIndex + 1) % records.count
        withAnimation(.easeInOut(duration: 0.6)) {
            scrollPosition = next
        }
    }
}

/// Card individual de um disco favorito (capa quadrada com cantos arredondados).
private struct FavoriteRecordCard: View {
    let record: DiscoModel
    let width: CGFloat
    let height: CGFloat

    var body: some View {
        Group {
            if let uiImage = UIImage(named: record.coverImageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.15)],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                    Image(systemName: "opticaldisc")
                        .font(.system(size: 40))
                        .foregroundStyle(.gray)
                }
            }
        }
        .frame(width: width, height: height)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.2), radius: 10, y: 6)
    }
}

#Preview {
    let previewRecords = [
        DiscoModel(title: "Master of Puppets", artist: "Metallica", coverImageName: "master_of_puppets"),
        DiscoModel(title: "PetroDragonic Apocalypse...", artist: "King Gizzard and the...", coverImageName: "petrodragonic"),
        DiscoModel(title: "Ride the Lightning", artist: "Metallica", coverImageName: "ride_the_lightning"),
        DiscoModel(title: "Igor", artist: "Tyler, The Creator", coverImageName: "igor")
    ]

    return DiscosFavCarrossel(records: previewRecords)
        .padding(.vertical)
        .background(Color(red: 0.98, green: 0.97, blue: 0.95))
}
