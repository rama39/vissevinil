//
//  DiscosFavCarrossel.swift
//  VisseVinil
//

import SwiftUI
import Combine

/// Carrossel de capas no estilo Apple Cover Flow.
///
/// A disposição 3D é calculada a partir da distância de cada capa em
/// relação a uma única posição contínua (`position`):
/// - capa central: reta, maior e totalmente opaca;
/// - capas laterais: giradas no eixo Y, menores, mais turvas e sobrepostas;
/// - todas as capas recebem uma reflexão abaixo, como no Cover Flow clássico.
struct DiscosFavCarrossel: View {
    let records: [_DiscoModel]
    var autoAdvanceInterval: TimeInterval = 3.0

    // MARK: - Cover Flow tuning

    private let coverSize: CGFloat = 210
    private let reflectionHeight: CGFloat = 92
    private let stackSpacing: CGFloat = -86
    private let sideRotationDegrees: Double = 52
    private let rotationRamp: Double = 2.6
    private let maxScaleReduction: CGFloat = 0.28
    private let maxOpacityReduction: Double = 0.28
    private let maxBlurRadius: CGFloat = 3
    private let perspective: CGFloat = 0.65

    @State private var position: CGFloat = 0
    @State private var dragStartPosition: CGFloat?

    private let timer: Publishers.Autoconnect<Timer.TimerPublisher>

    private var itemHeight: CGFloat { coverSize + 8 + reflectionHeight }
    private var itemStride: CGFloat { coverSize + stackSpacing }

    init(records: [_DiscoModel], autoAdvanceInterval: TimeInterval = 3.0) {
        self.records = records
        self.autoAdvanceInterval = autoAdvanceInterval
        self.timer = Timer.publish(
            every: max(autoAdvanceInterval, 0.1),
            on: .main,
            in: .common
        ).autoconnect()
    }

    private var selectedIndex: Int {
        guard !records.isEmpty else { return 0 }
        let count = records.count
        let rounded = Int(position.rounded())
        return ((rounded % count) + count) % count
    }

    var body: some View {
        VStack(spacing: 14) {
            coverFlow

            if records.indices.contains(selectedIndex) {
                VStack(spacing: 2) {
                    Text(records[selectedIndex].title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.88))
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Text(records[selectedIndex].artistsListed)
                        .font(.system(size: 14))
                        .foregroundStyle(.black.opacity(0.48))
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .frame(maxWidth: 280)
                .id(selectedIndex)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.25), value: selectedIndex)
            }

            if records.count > 1 {
                HStack(spacing: 6) {
                    ForEach(records.indices, id: \.self) { index in
                        Circle()
                            .fill(
                                index == selectedIndex
                                    ? Color.black.opacity(0.75)
                                    : Color.gray.opacity(0.30)
                            )
                            .frame(width: 6, height: 6)
                            .animation(.easeInOut(duration: 0.25), value: selectedIndex)
                    }
                }
            }
        }
        .onReceive(timer) { _ in
            advanceToNext()
        }
        .onAppear {
            guard !records.isEmpty else { return }
            position = 0
        }
    }

    // MARK: - Cover Flow

    private var coverFlow: some View {
        GeometryReader { outerGeo in
            let containerWidth = outerGeo.size.width

            ZStack {
                ForEach(Array(records.enumerated()), id: \.element.id) { index, record in
                    let distance = wrappedDistance(forIndex: index, count: records.count)
                    let normalizedDistance = min(abs(distance), 1.35)
                    let rotationAmount = min(max(distance * rotationRamp, -1), 1)
                    let scale = 1 - (normalizedDistance / 1.35 * maxScaleReduction)
                    let opacity = 1 - (normalizedDistance / 1.35 * maxOpacityReduction)
                    let blur = normalizedDistance / 1.35 * maxBlurRadius

                    FavoriteDiscoCard(record: record, coverSize: coverSize, reflectionHeight: reflectionHeight)
                        .frame(width: coverSize, height: itemHeight)
                        .scaleEffect(scale)
                        .opacity(opacity)
                        .blur(radius: blur)
                        .rotation3DEffect(
                            .degrees(rotationAmount * -sideRotationDegrees),
                            axis: (x: 0, y: 1, z: 0),
                            anchor: rotationAmount >= 0 ? .leading : .trailing,
                            anchorZ: 0,
                            perspective: perspective
                        )
                        .offset(x: distance * itemStride)
                        .zIndex(10_000 - abs(distance) * 1_000)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            snapTo(index)
                        }
                }
            }
            .frame(width: containerWidth, height: itemHeight)
            .contentShape(Rectangle())
            .gesture(dragGesture)
        }
        .frame(height: itemHeight + 20)
        .clipped()
    }

    private func wrappedDistance(forIndex index: Int, count: Int) -> CGFloat {
        guard count > 0 else { return 0 }
        let countF = CGFloat(count)
        var raw = (CGFloat(index) - position).truncatingRemainder(dividingBy: countF)
        if raw > countF / 2 { raw -= countF }
        if raw < -countF / 2 { raw += countF }
        return raw
    }

    // MARK: - Gestos

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                if dragStartPosition == nil {
                    dragStartPosition = position
                }
                guard let start = dragStartPosition else { return }
                position = start - value.translation.width / itemStride
            }
            .onEnded { _ in
                dragStartPosition = nil
                withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                    position = position.rounded()
                }
            }
    }

    // MARK: - Navigation

    private func snapTo(_ index: Int) {
        guard records.indices.contains(index) else { return }
        let delta = wrappedDistance(forIndex: index, count: records.count)
        withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
            position += delta
        }
    }

    private func advanceToNext() {
        guard records.count > 1 else { return }
        withAnimation(.spring(response: 0.60, dampingFraction: 0.86)) {
            position += 1
        }
    }
}

// MARK: - Card

/// Capa do disco + reflexo invertido e esmaecido.
private struct FavoriteDiscoCard: View {
    let record: _DiscoModel
    let coverSize: CGFloat
    let reflectionHeight: CGFloat

    var body: some View {
        VStack(spacing: 8) {
            cover
                .frame(width: coverSize, height: coverSize)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(.white.opacity(0.16), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.28), radius: 16, x: 0, y: 10)

            cover
                .frame(width: coverSize, height: reflectionHeight)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                .scaleEffect(x: 1, y: -1)
                .mask {
                    LinearGradient(
                        stops: [
                            .init(color: .white.opacity(0.28), location: 0),
                            .init(color: .white.opacity(0.10), location: 0.30),
                            .init(color: .clear, location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .allowsHitTesting(false)
        }
    }

    private var cover: some View {
        Group {
            if let coverImage = record.coverImage {
                coverImage
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    LinearGradient(
                        colors: [.gray.opacity(0.30), .gray.opacity(0.15)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: "opticaldisc")
                        .font(.system(size: 40))
                        .foregroundStyle(.gray)
                }
            }
        }
    }
}

/// Monta um _DiscoModel só com o que o preview precisa (título e artista).
private func previewDisco(title: String, artist: String, posicao: Int) -> _DiscoModel {
    _DiscoModel(
        master_title: title,
        artists: [MasterArtist(join: nil, name: artist, anv: nil, tracks: nil, role: nil, resourceURL: nil, id: nil)],
        master_id: nil,
        title: title,
        id: posicao,
        posicao: posicao
    )
}

#Preview {
    let previewRecords = [
        previewDisco(title: "Master of Puppets", artist: "Metallica", posicao: 0),
        previewDisco(title: "PetroDragonic Apocalypse...", artist: "King Gizzard and the...", posicao: 1),
        previewDisco(title: "Ride the Lightning", artist: "Metallica", posicao: 2),
        previewDisco(title: "Igor", artist: "Tyler, The Creator", posicao: 3)
    ]

    return DiscosFavCarrossel(records: previewRecords)
        .padding(.vertical)
        .background(Color(red: 0.98, green: 0.97, blue: 0.95))
}
