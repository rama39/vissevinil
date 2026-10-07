//
//  DiscosFavCarrossel.swift
//  VisseVinil
//

import SwiftUI
import SwiftData
import Combine

/// Carrossel de capas no estilo Apple Cover Flow, sobre água.
///
/// A disposição 3D é calculada a partir da distância de cada capa em
/// relação a uma única posição contínua (`position`):
/// - capa central: reta, maior e totalmente opaca;
/// - capas laterais: giradas no eixo Y, menores, mais turvas e sobrepostas;
/// - embaixo, o reflexo das capas numa superfície de água (shader Agua.metal): sempre com
///   uma ondulação calma; ao arrastar o carrossel a água se agita e vai acalmando, e um
///   toque na água abre uma onda a partir do dedo.
/// Tocar na capa do centro abre o disco; tocar numa lateral traz ela pro centro.
/// Com "Reduzir Movimento", a água fica parada e o carrossel não avança sozinho; com
/// "Reduzir Transparência", o reflexo some (é só decorativo).
struct DiscosFavCarrossel: View {
    let records: [DiscoModel]
    var autoAdvanceInterval: TimeInterval = 3.0
    /// Capa do centro tocada (quem abre o disco é a tela que usa o carrossel)
    var onRecordTapped: (DiscoModel) -> Void = { _ in }

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

    // MARK: - Água

    // Agitação da água: valor no momento do último empurrão, que vai decaindo com o tempo
    @State private var agitacao: Double = 0
    @State private var inicioDaAgitacao = Date.distantPast
    // Onda circular do último toque na água
    @State private var origemDaOnda: CGPoint = .zero
    @State private var inicioDaOnda = Date.distantPast
    @State private var visivel = false

    @Environment(\.accessibilityReduceMotion) private var reduzirMovimento
    @Environment(\.accessibilityReduceTransparency) private var reduzirTransparencia

    private let timer: Publishers.Autoconnect<Timer.TimerPublisher>

    private var itemStride: CGFloat { coverSize + stackSpacing }

    init(records: [DiscoModel], autoAdvanceInterval: TimeInterval = 3.0,
         onRecordTapped: @escaping (DiscoModel) -> Void = { _ in }) {
        self.records = records
        self.autoAdvanceInterval = autoAdvanceInterval
        self.onRecordTapped = onRecordTapped
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

    private var visibleIndices: [Int] {
        guard !records.isEmpty else { return [] }

        let count = records.count
        let center = selectedIndex

        // Sem repetir a mesma capa quando há menos de 3 discos
        return Array(Set([-1, 0, 1].map { offset in
            (center + offset + count) % count
        })).sorted()
    }

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometria in
                let largura = geometria.size.width

                VStack(spacing: 0) {
                    capas(largura: largura, interativas: true)
                        .gesture(dragGesture)

                    if !reduzirTransparencia {
                        agua(largura: largura)
                    }
                }
            }
            .frame(height: coverSize + (reduzirTransparencia ? 0 : reflectionHeight))
            .padding(.bottom, 8)

            if records.indices.contains(selectedIndex) {
                VStack(spacing: 2) {
                    Text(records[selectedIndex].title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Text(records[selectedIndex].artistsListed)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .frame(maxWidth: 280)
                .id(selectedIndex)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.25), value: selectedIndex)
                // Já lido em cada capa pelo VoiceOver
                .accessibilityHidden(true)
            }

            if records.count > 1 {
                HStack(spacing: 6) {
                    ForEach(records.indices, id: \.self) { index in
                        Circle()
                            .fill(
                                index == selectedIndex
                                    ? Color.primary.opacity(0.85)
                                    : Color(.systemGray4)
                            )
                            .frame(width: 6, height: 6)
                            .animation(.easeInOut(duration: 0.25), value: selectedIndex)
                    }
                }
                .padding(.top, 8)
                .accessibilityHidden(true)
            }
        }
        .onReceive(timer) { _ in
            // Conteúdo que se mexe sozinho incomoda quem pediu pra reduzir movimento
            guard !reduzirMovimento else { return }
            advanceToNext()
        }
        .onAppear {
            visivel = true
            guard !records.isEmpty else { return }
            position = 0
        }
        .onDisappear {
            visivel = false
        }
    }

    // MARK: - Cover Flow

    /// As capas em leque. Desenhadas duas vezes: em cima (com toque) e espelhadas na água.
    private func capas(largura: CGFloat, interativas: Bool) -> some View {
        ZStack {
            ForEach(visibleIndices, id: \.self) { index in
                let record = records[index]

                let distance = wrappedDistance(
                    forIndex: index,
                    count: records.count
                )

                let normalizedDistance = min(abs(distance), 1.35)
                let rotationAmount = min(max(distance * rotationRamp, -1), 1)
                let scale = 1 - (normalizedDistance / 1.35 * maxScaleReduction)
                let opacity = 1 - (normalizedDistance / 1.35 * maxOpacityReduction)
                let blur = normalizedDistance / 1.35 * maxBlurRadius

                FavoriteDiscoCard(record: record, coverSize: coverSize, comSombra: interativas)
                    .scaleEffect(scale)
                    .opacity(opacity)
                    .blur(radius: blur)
                    .rotation3DEffect(
                        .degrees(rotationAmount * -sideRotationDegrees),
                        axis: (x: 0, y: 1, z: 0),
                        anchor: .center,
                        anchorZ: 0,
                        perspective: perspective
                    )
                    .offset(x: distance * itemStride)
                    .zIndex(10_000 - abs(distance) * 1_000)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard interativas else { return }
                        if selectedIndex == index {
                            onRecordTapped(record)
                        } else {
                            snapTo(index)
                        }
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel(record.artistsListed.isEmpty
                                        ? record.title
                                        : "\(record.title), de \(record.artistsListed)")
                    .accessibilityAddTraits(.isButton)
                    .accessibilityAction { onRecordTapped(record) }
            }
        }
        .frame(width: largura, height: coverSize)
        .contentShape(Rectangle())
    }

    /// Reflexo das capas numa superfície de água: espelhado, sumindo num degradê e distorcido
    /// pelo shader Agua.metal. Arrastar aqui também move o carrossel; tocar abre uma onda.
    private func agua(largura: CGFloat) -> some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0, paused: reduzirMovimento || !visivel)) { contexto in
            let agora = contexto.date
            let tempo = reduzirMovimento ? 0 : agora.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 1_000)
            let idadeDaOnda = agora.timeIntervalSince(inicioDaOnda)

            capas(largura: largura, interativas: false)
                // De cabeça pra baixo, mostrando a parte de baixo das capas colada na linha d'água
                .scaleEffect(x: 1, y: -1, anchor: .center)
                .frame(width: largura, height: reflectionHeight, alignment: .top)
                .clipped()
                .distortionEffect(
                    ShaderLibrary.agua(
                        .float(Float(tempo)),
                        .float(Float(reduzirMovimento ? 0 : agitacaoAtual(em: agora))),
                        .float2(Float(largura), Float(reflectionHeight)),
                        .float2(Float(origemDaOnda.x), Float(origemDaOnda.y)),
                        .float(Float(reduzirMovimento ? -1 : idadeDaOnda))
                    ),
                    maxSampleOffset: CGSize(width: 16, height: 16)
                )
                .mask {
                    LinearGradient(colors: [.white.opacity(0.42), .white.opacity(0.12), .clear],
                                   startPoint: .top, endPoint: .bottom)
                }
        }
        .frame(width: largura, height: reflectionHeight)
        .contentShape(Rectangle())
        .gesture(dragGesture)
        .onTapGesture { ponto in
            origemDaOnda = ponto
            inicioDaOnda = .now
        }
        .accessibilityHidden(true)
    }

    private func wrappedDistance(forIndex index: Int, count: Int) -> CGFloat {
        guard count > 0 else { return 0 }
        let countF = CGFloat(count)
        var raw = (CGFloat(index) - position).truncatingRemainder(dividingBy: countF)
        if raw > countF / 2 { raw -= countF }
        if raw < -countF / 2 { raw += countF }
        return raw
    }

    // MARK: - Água: agitação

    // Decai sozinha: em ~1,5 s a água volta a ficar calma
    private func agitacaoAtual(em data: Date) -> Double {
        let tempoDesde = max(data.timeIntervalSince(inicioDaAgitacao), 0)
        return agitacao * exp(-tempoDesde * 1.8)
    }

    private func agitar(_ intensidade: Double) {
        let agora = Date.now
        agitacao = min(1, max(agitacaoAtual(em: agora), intensidade))
        inicioDaAgitacao = agora
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
                // Quanto mais rápido o arraste, mais a água se agita
                agitar(min(abs(value.velocity.width) / 1_800, 1))
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
        agitar(0.35)
        withAnimation(.spring(response: 0.55, dampingFraction: 0.82)) {
            position += delta
        }
    }

    private func advanceToNext() {
        guard records.count > 1 else { return }
        agitar(0.25)
        withAnimation(.spring(response: 0.60, dampingFraction: 0.86)) {
            position += 1
        }
    }
}

// MARK: - Card

/// Capa do disco (a capa grande do Discogs; enquanto carrega, a miniatura salva).
private struct FavoriteDiscoCard: View {
    let record: DiscoModel
    let coverSize: CGFloat
    var comSombra = true

    @State private var imagemGrande: UIImage?

    var body: some View {
        cover
            .frame(width: coverSize, height: coverSize)
            .clipShape(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(.white.opacity(0.16), lineWidth: 1)
            }
            .shadow(
                color: .black.opacity(comSombra ? 0.28 : 0),
                radius: 16,
                x: 0,
                y: 10
            )
            .task(id: record.persistentModelID) {
                imagemGrande = await CacheDeCapas.imagemGrande(de: record)
            }
    }

    private var cover: some View {
        Group {
            if let imagemGrande {
                Image(uiImage: imagemGrande)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFill()
            } else if let coverImage = record.coverImage {
                coverImage
                    .resizable()
                    .interpolation(.high)
                    .scaledToFill()
            } else {
                ZStack {
                    LinearGradient(
                        colors: [Color(.systemGray5), Color(.systemGray6)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Image(systemName: "opticaldisc")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

/// Monta um DiscoModel só com o que o preview precisa (título e artista).
private func previewDisco(title: String, artist: String, posicao: Int) -> DiscoModel {
    DiscoModel(
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
        .background(Color(.systemGroupedBackground))
}
