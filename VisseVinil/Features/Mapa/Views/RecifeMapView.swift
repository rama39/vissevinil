//
//  RecifeMapView.swift
//  VisseVinil
//
//  Created by Gabriel Alves Gadelha de Melo on 11/09/26.
//

import SwiftUI
import MapKit
import ClusterMapSwiftUI
import SwiftData

/*
===============================================================================================
 - Struct x Class -> classes, quando chamadas em outra parte do código, é utilizada a mesma
instância, sem criar cópias;
- Ao utilizar o CLLocationManeger, precisamos que o código tbm aceite as regras antigas da
Apple, por isso o NSObject;
===============================================================================================
*/

/**
 =================================================================================
 "Locator é uma caixa (class) que fala o idioma antigo da Apple pra poder conversar com o GPS (NSObject), é transparente para o
 SwiftUI perceber mudanças (@Observable), e só pode ser mexida na thread principal por segurança (@MainActor)"
 =================================================================================
 **/
@MainActor
@Observable
class Locator: NSObject, CLLocationManagerDelegate {
    
    //===============================================================================================
    
    //--------------------------------------------------------------------------------------
    // Classe do framework CoreLocation responsável por conversar com o GPS do dispositivo
    private let manager = CLLocationManager()
    
    // Salva a última localização conhecida
    var currentLocalization: CLLocationCoordinate2D?
    //--------------------------------------------------------------------------------------
    
    //===============================================================================================
    
    //--------------------------------------------------------------------------------------
    // Como Locator herda de NSObject e essa classe já tem um init, precisamos sobrescrever
    override init() {
        // Chama o init original da classe mãe
        super.init()
        // Locator "escuta" CLLocationManager
        manager.delegate = self
    }
    //--------------------------------------------------------------------------------------
    
    //===============================================================================================
    
    //--------------------------------------------------------------------------------------
    // Pedir o acesso à localização do usuário
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        // Liga o GPS e começa a receber atualizações da posição
        manager.startUpdatingLocation()
    }
    //--------------------------------------------------------------------------------------
    
    //===============================================================================================
    /*
     Esse é o método do protocolo CLLocationManagerDelegate, é uma exigência da Apple: pra "escutar
     atualizações de localização. O sistema chama esse método sozinho, automaticamente, toda vez que
     o GPS tem uma posição nova
    */
    //--------------------------------------------------------------------------------------
    // Essa função específica é a exceção, ela pode rodar fora da main thread
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Guarda a localização mais recente do usuário
        guard let lastLocalization = locations.last else { return }
        // Cria uma nova tarefa assíncrona que roda especificamente na main thread, já que
        // currentLocalization precisa ser atualizada na main thread
        Task {
            @MainActor in
            currentLocalization = lastLocalization.coordinate
        }
    }
    //--------------------------------------------------------------------------------------
}

//===================================================================================================
// View Principal do mapa
struct RecifeMapView: View {
    
    struct RecenteSalvo: Codable, Identifiable {
        let id: UUID
        let nome: String
        let latitude: Double
        let longitude: Double
        let endereco: String?
    }
    
    private var favoritos: [Loja] {
        let todasConhecidas = lojas + recentes
        var vistos = Set<String>()
        var resultado: [Loja] = []

        for loja in todasConhecidas where ehFavorito(loja) {
            let chaveLoja = chave(para: loja)
            if !vistos.contains(chaveLoja) {
                vistos.insert(chaveLoja)
                resultado.append(loja)
            }
        }

        return resultado
    }
    
    // Declaração da lista de Lojas
    @State private var lojas: [Loja] = [
        Loja(nameForSearch: "R Vinil e CDs",
             coordinate: CLLocationCoordinate2D(latitude: -8.03734, longitude: -34.89216),
             ig: nil),
        Loja(nameForSearch: "Vinil Alternativo",
             coordinate: CLLocationCoordinate2D(latitude: -8.06214, longitude: -34.88369),
             ig: nil),
        Loja(nameForSearch: "Pulga Mercado de Discos",
             coordinate: CLLocationCoordinate2D(latitude: -8.03924, longitude: -34.89467),
             ig: nil),
        Loja(nameForSearch: "Taberna do Vinil",
             coordinate: CLLocationCoordinate2D(latitude: -8.03940, longitude: -34.89471),
             ig: nil),
        Loja(nameForSearch: "Bolacha Discos e Coisas",
             coordinate: CLLocationCoordinate2D(latitude: -8.04789, longitude: -34.89889),
             ig: nil),
        Loja(nameForSearch: "Disco de Ouro",
             coordinate: CLLocationCoordinate2D(latitude: -8.06040, longitude: -34.88291),
             ig: nil),
        Loja(nameForSearch: "Blackout Discos",
             coordinate: CLLocationCoordinate2D(latitude: -8.06003, longitude: -34.88234),
             ig: nil),
        Loja(nameForSearch: "Flowers Records Brazil",
             coordinate: CLLocationCoordinate2D(latitude: -8.06222, longitude: -34.88272),
             ig: nil),
        Loja(nameForSearch: "CD & Cia",
             coordinate: CLLocationCoordinate2D(latitude: -8.06209, longitude: -34.88209),
             ig: nil),
        Loja(nameForSearch: "Sebo Pereira",
             coordinate: CLLocationCoordinate2D(latitude: -8.05799, longitude: -34.88632),
             ig: nil),
        Loja(nameForSearch: "Praça do Sebo (Estandes Diversos)",
             coordinate: CLLocationCoordinate2D(latitude: -8.06306, longitude: -34.87872),
             ig: nil),
        Loja(nameForSearch: "Fernando Vinil Discos",
             coordinate: CLLocationCoordinate2D(latitude: -8.04147, longitude: -34.89415),
             ig: nil),
        Loja(nameForSearch: "Sebo da Torre",
             coordinate: CLLocationCoordinate2D(latitude: -8.04526, longitude: -34.90721),
             ig: nil)
    ]
    
    /*
    ===============================================================================================
     Imagine que existe uma câmera em cima do globo, precisamos definir duas coisas:
        - Onde ela está posicionada;
        - A que altura ela está.
     
     Dessa forma, como queremos limitar apenas Recife, devemos "prender" o usuário nessa posição.
    ===============================================================================================
    */
    
    /**
     =================================================================================
     "Eu declaro que vou ter uma posição de câmera (cameraPosition), mas só decido qual vai ser o valor inicial dela
     quando a View for realmente criada (init), porque esse valor depende da variável rmretropolyRegion. E o valor
     escolhido é: 'segue o usuário se possível, senão mostra a cidade inteira'."
     =================================================================================
     */
    private let metropolyRegion = MKCoordinateRegion (
        center: CLLocationCoordinate2D(latitude: -8.0576, longitude: -34.9050),
        span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.20)
    )
    
    // Limitantes do Zoom
    private let minimumZoom: CLLocationDistance = 500
    private let maximumZoom: CLLocationDistance = 85000
    
    @State private var recentesSalvos: [RecenteSalvo] = []
    private var recentes: [Loja] {
        recentesSalvos.map(loja(de:))
    }

    private func loja(de recente: RecenteSalvo) -> Loja {
        let loja = Loja(
            nameForSearch: recente.nome,
            coordinate: CLLocationCoordinate2D(latitude: recente.latitude, longitude: recente.longitude)
        )
        loja.address = recente.endereco
        return loja
    }
    
    private func chave(para loja: Loja) -> String {
        "\(loja.latitude),\(loja.longitude)"
    }
    
    // Distância da câmera (zoom) usada ao abrir um local pela busca, recentes ou favoritos
    private let distanciaDeFoco: CLLocationDistance = 1500

    @State private var coordenadasFavoritas: Set<String> = []
    @FocusState private var campoFocado: Bool
    @State private var searchCompleter = SearchCompleter()
    @State private var textoBusca = ""
    @State private var pontoPesquisado: Loja?
    @State private var cameraPosition: MapCameraPosition
    @State private var shopClusterManager = ShopClusterManager()
    @State private var tarefaDeAtualizacao: Task<Void, Never>?
    @State private var lojaSelecionada: Loja?
    @State private var alturaMapa: CGFloat = 0
    @State private var cameraAtual: MapCamera?
    /*
     Com a câmera olhando reto pra baixo, quantos graus de latitude cabem em 1 ponto da tela é
     proporcional à distância da câmera. Medimos essa proporção com o mapa parado e daí dá pra
     calcular exatamente onde a loja vai aparecer em QUALQUER zoom, antes mesmo de mover a câmera.
    */
    @State private var grausPorPontoPorMetro: Double?
    // Onde (em y) o centro da câmera aparece dentro do mapa
    @State private var yCentroDaCamera: CGFloat?
    @State private var jaCentralizouNoUsuario = false
    // true quando a seleção veio da busca/recentes/favoritos (zoom padronizado, estilo Mapas do iPhone)
    @State private var selecaoVeioDaBusca = false
    // Detent atual da sheet: sempre volta pro reduzido ao selecionar uma loja
    @State private var detenteDaSheet: PresentationDetent
    @State private var tecladoVisivel = false
    private var locator = Locator()
    private let alturaSheetReduzida: CGFloat = 340
    private let espacamentoAcimaDaSheet: CGFloat = 40
    
    // Funciona basicamente como um constructor de RecifeMapView
    init() {
        _cameraPosition = State(initialValue: .userLocation(fallback: .region(metropolyRegion)))
        _detenteDaSheet = State(initialValue: .height(alturaSheetReduzida))
    }
    
    @State private var mapProxyAtual: MapProxy?

    var body: some View {
        ZStack(alignment: .top) {
            // Mapa ocupa a tela inteira e nunca muda de tamanho (nem com teclado, nem com a sheet),
            // o que deixa as contas de posicionamento estáveis
            mapaCompleto
                .ignoresSafeArea()
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { alturaMapa = $0 }

            if campoFocado {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .transition(.opacity)
            }

            VStack(spacing: 0) {
                // Com a sheet aberta não dá pra pesquisar: a barra some
                if lojaSelecionada == nil {
                    barraDeBusca
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                }

                if campoFocado {
                    Group {
                        if textoBusca.isEmpty {
                            searchOverlay
                        } else {
                            suggestionsList
                        }
                    }
                    .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.25), value: lojaSelecionada == nil)
            .animation(.easeInOut(duration: 0.25), value: textoBusca.isEmpty)
        }
        .animation(.easeInOut(duration: 0.25), value: campoFocado)
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
            tecladoVisivel = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidHideNotification)) { _ in
            tecladoVisivel = false
        }
        .onChange(of: textoBusca) { _, novoTexto in
            searchCompleter.buscar(novoTexto)
        }
    }

    // Barra própria (em vez de .searchable) pra poder esconder quando a sheet abre
    private var barraDeBusca: some View {
        HStack(spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                TextField("Buscar local", text: $textoBusca)
                    .focused($campoFocado)
                    .submitLabel(.search)
                    .autocorrectionDisabled()
                    .onSubmit {
                        if let primeira = searchCompleter.sugestoes.first {
                            selecionarSugestao(primeira)
                        }
                    }

                if !textoBusca.isEmpty {
                    Button {
                        textoBusca = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .glassEffect(.regular.interactive(), in: .capsule)

            if campoFocado {
                Button("Cancelar") {
                    fecharBusca()
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: campoFocado)
    }

    private func fecharBusca() {
        textoBusca = ""
        searchCompleter.limpar()
        campoFocado = false
    }

    private var searchOverlay: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if !favoritos.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Favoritos")
                            .font(.headline)
                            .padding(.horizontal)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(favoritos) { loja in
                                    Button {
                                        selecionarLojaDaBusca(loja)
                                    } label: {
                                        VStack(spacing: 8) {
                                            Circle()
                                                .fill(.blue.gradient)
                                                .frame(width: 56, height: 56)
                                                .overlay {
                                                    Image(systemName: "star.fill")
                                                        .foregroundStyle(.white)
                                                }
                                            Text(loja.nameForSearch)
                                                .font(.caption)
                                                .lineLimit(1)
                                                .frame(width: 72)
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }

                if !recentesSalvos.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Recentes")
                            .font(.headline)
                            .padding(.horizontal)

                        VStack(spacing: 0) {
                            ForEach(recentesSalvos) { recente in
                                Button {
                                    selecionarLojaDaBusca(loja(de: recente))
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(systemName: "clock")
                                            .foregroundStyle(.secondary)
                                            .frame(width: 28)

                                        VStack(alignment: .leading) {
                                            Text(recente.nome)
                                            if let endereco = recente.endereco {
                                                Text(endereco)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                                    .lineLimit(1)
                                            }
                                        }

                                        Spacer()
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal)
                                }
                                .buttonStyle(.plain)

                                Divider().padding(.leading, 52)
                            }
                        }
                    }
                }

                if favoritos.isEmpty && recentesSalvos.isEmpty {
                    Text("Suas buscas recentes e favoritos vão aparecer aqui.")
                        .foregroundStyle(.secondary)
                        .padding()
                }
            }
            .padding(.top, 12)
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
    private var suggestionsList: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(searchCompleter.sugestoes, id: \.self) { sugestao in
                    Button {
                        selecionarSugestao(sugestao)
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .foregroundStyle(.secondary)
                                .frame(width: 28)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(sugestao.title)
                                    .foregroundStyle(.primary)

                                if !sugestao.subtitle.isEmpty {
                                    Text(sugestao.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }

                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)

                    Divider().padding(.leading, 52)
                }
            }
            .padding(.top, 12)
        }
        .scrollDismissesKeyboard(.immediately)
    }
    
    //===============================================================================================
    /**
     =================================================================================
     Faz o mapa mostrar a "Principal" Região Metropolitana do Recife  e "prende" o usuário nela.
     =================================================================================
     **/
    private var mapaCompleto: some View {
        MapReader { mapProxy in
            Map(
                position: $cameraPosition,
                bounds: MapCameraBounds(
                    centerCoordinateBounds: metropolyRegion,
                    minimumDistance: minimumZoom,
                    maximumDistance: maximumZoom
                ),
                selection: $lojaSelecionada
            ) {
                UserAnnotation()

                ForEach(shopClusterManager.visibleLojas) { loja in
                    Marker(loja.nameForSearch, systemImage: "storefront", coordinate: loja.coordinate)
                        .tint(.blue)
                        .tag(loja)
                }

                ForEach(shopClusterManager.visibleGroups) { group in
                    Annotation("", coordinate: group.coordinate) {
                        ZStack {
                            Circle()
                                .fill(.orange.gradient)
                                .background(Circle().fill(.ultraThinMaterial))
                                .overlay(Circle().strokeBorder(.white.opacity(0.6), lineWidth: 1.5))
                                .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 3)
                                .frame(width: 56, height: 56)

                            Text("+\(group.count)")
                                .font(.callout.bold())
                                .foregroundStyle(.white)
                        }
                        .onTapGesture {
                            zoomToFit(group)
                        }
                    }
                }
                
                if let pesquisado = pontoPesquisado {
                    Marker(pesquisado.nameForSearch, systemImage: "mappin", coordinate: pesquisado.coordinate)
                        .tint(.red)
                        // Sem a tag o Map não reconhece o pin como selecionado e ele não expande
                        .tag(pesquisado)
                }
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .onMapCameraChange(frequency: .onEnd) { context in
                cameraAtual = context.camera
                calibrarEscala(camera: context.camera, mapProxy: mapProxy)
                searchCompleter.atualizarRegiao(context.region)
                shopClusterManager.limparForcadosSeAfastado(distanciaAtual: context.camera.distance)
                agendarAtualizacaoDosClusters(mapProxy: mapProxy)
            }
            .onChange(of: lojaSelecionada) { _, novaLoja in
                guard let loja = novaLoja else {
                    pontoPesquisado = nil
                    shopClusterManager.destacar(nil)
                    agendarAtualizacaoDosClusters(mapProxy: mapProxy)
                    return
                }

                detenteDaSheet = .height(alturaSheetReduzida)
                let veioDaBusca = selecaoVeioDaBusca
                selecaoVeioDaBusca = false
                focar(loja, mapProxy: mapProxy, zoomPadrao: veioDaBusca)
                registrarRecente(loja)
            }
            .onChange(of: locator.currentLocalization) { _, newLocalization in
                // Só posiciona no usuário na primeira localização; depois disso cada atualização
                // do GPS jogaria a câmera de volta pro usuário, desfazendo o foco na loja
                guard !jaCentralizouNoUsuario, lojaSelecionada == nil else { return }
                jaCentralizouNoUsuario = true
                setCameraWith(newLocalization)
            }
            .task {
                shopClusterManager.setLojas(lojas)
                await shopClusterManager.updateClusters(mapProxy: mapProxy)
            }
            .onAppear {
                locator.requestLocation()
                mapProxyAtual = mapProxy
                carregarRecentes()
                carregarFavoritos()
            }
            .sheet(item: $lojaSelecionada) { loja in
                LojaDetailView(
                    loja: loja,
                    ehFavorito: ehFavorito(loja),
                    onToggleFavorito: { alternarFavorito(loja) }
                )
                .presentationDetents([.height(alturaSheetReduzida), .large], selection: $detenteDaSheet)
                .presentationDragIndicator(.visible)
                .presentationBackgroundInteraction(.enabled(upThrough: .height(alturaSheetReduzida)))
            }
        }
    }
    
    private func registrarRecente(_ loja: Loja) {
        guard loja.latitude != 0, loja.longitude != 0 else { return }

        recentesSalvos.removeAll {
            $0.latitude == loja.latitude && $0.longitude == loja.longitude
        }

        let novoRecente = RecenteSalvo(
            id: UUID(),
            nome: loja.nameForSearch,
            latitude: loja.latitude,
            longitude: loja.longitude,
            endereco: loja.address
        )

        recentesSalvos.insert(novoRecente, at: 0)
        if recentesSalvos.count > 7 {
            recentesSalvos.removeLast(recentesSalvos.count - 7)
        }

        salvarRecentes()
    }
    
    private func salvarRecentes() {
        if let dados = try? JSONEncoder().encode(recentesSalvos) {
            UserDefaults.standard.set(dados, forKey: "recentesSalvos")
        }
    }
    
    private func carregarRecentes() {
        guard let dados = UserDefaults.standard.data(forKey: "recentesSalvos"),
              let decodificado = try? JSONDecoder().decode([RecenteSalvo].self, from: dados) else { return }
        recentesSalvos = decodificado
    }
    
    private func selecionarSugestao(_ sugestao: MKLocalSearchCompletion) {
        Task {
            let requisicao = MKLocalSearch.Request(completion: sugestao)
            let busca = MKLocalSearch(request: requisicao)

            do {
                let resposta = try await busca.start()
                guard let item = resposta.mapItems.first else { return }
                selecionarResultado(item)
            } catch {
                // busca falhou silenciosamente; poderia mostrar um aviso se quiser
            }
        }
    }
    
    private func selecionarResultado(_ item: MKMapItem) {
        let coordenada = item.location.coordinate
        let candidata = Loja(nameForSearch: item.name ?? "Local", coordinate: coordenada)

        if let original = lojaCadastradaCorrespondente(candidata) {
            original.officialName = item.name
            original.category = item.pointOfInterestCategory?.rawValue
            original.address = item.address?.fullAddress
            original.fone = item.phoneNumber
            original.website = item.url?.absoluteString
            abrir(original)
        } else {
            candidata.officialName = item.name
            candidata.category = item.pointOfInterestCategory?.rawValue
            candidata.address = item.address?.fullAddress
            candidata.fone = item.phoneNumber
            candidata.website = item.url?.absoluteString
            abrir(candidata)
        }
    }
    
    private func selecionarLojaDaBusca(_ loja: Loja) {
        abrir(lojaCadastradaCorrespondente(loja) ?? loja)
    }

    // Caminho comum de busca, recentes e favoritos: fecha a busca primeiro e só depois
    // seleciona. Se a sheet for apresentada enquanto a barra de busca/teclado ainda estão
    // fechando, o iOS pode descartar a apresentação e o mapa mede uma altura errada.
    private func abrir(_ loja: Loja) {
        fecharBusca()
        // O pin vermelho já precisa existir no mapa quando a seleção chegar, senão não expande
        if !lojas.contains(loja) {
            pontoPesquisado = loja
        }
        Task {
            // Se a sheet for apresentada com o teclado ainda na tela, o iOS abre ela em .large.
            // Espera o teclado sumir de verdade (com um limite de ~1,5 s pra nunca travar).
            try? await Task.sleep(for: .milliseconds(150))
            for _ in 0..<27 where tecladoVisivel {
                try? await Task.sleep(for: .milliseconds(50))
            }
            try? await Task.sleep(for: .milliseconds(100))
            detenteDaSheet = .height(alturaSheetReduzida)
            if loja == lojaSelecionada {
                // onChange não dispara pra mesma loja, então foca manualmente
                if let mapProxyAtual { focar(loja, mapProxy: mapProxyAtual, zoomPadrao: true) }
            } else {
                selecaoVeioDaBusca = true
                lojaSelecionada = loja
            }
        }
    }

    private func focar(_ loja: Loja, mapProxy: MapProxy, zoomPadrao: Bool) {
        let cadastrada = lojas.contains(loja)
        // Loja cadastrada usa o próprio Marker azul; só local avulso ganha o pin vermelho
        pontoPesquisado = cadastrada ? nil : loja
        shopClusterManager.destacar(cadastrada ? loja : nil)
        agendarAtualizacaoDosClusters(mapProxy: mapProxy)
        // Toque no pin mantém o zoom do usuário; busca/recentes/favoritos (ou local avulso)
        // sempre vão pro mesmo zoom, aproximando ou afastando conforme o necessário
        centralizarParaSheet(loja: loja, zoomPadrao: zoomPadrao || !cadastrada)
    }

    private func agendarAtualizacaoDosClusters(mapProxy: MapProxy) {
        tarefaDeAtualizacao?.cancel()
        tarefaDeAtualizacao = Task {
            try? await Task.sleep(for: .seconds(0.3))
            guard !Task.isCancelled else { return }
            await shopClusterManager.updateClusters(mapProxy: mapProxy)
        }
    }
    
    private func ehFavorito(_ loja: Loja) -> Bool {
        coordenadasFavoritas.contains(chave(para: loja))
    }

    private func alternarFavorito(_ loja: Loja) {
        let chaveLoja = chave(para: loja)
        if coordenadasFavoritas.contains(chaveLoja) {
            coordenadasFavoritas.remove(chaveLoja)
        } else {
            coordenadasFavoritas.insert(chaveLoja)
        }
        salvarFavoritos()
    }

    private func salvarFavoritos() {
        UserDefaults.standard.set(Array(coordenadasFavoritas), forKey: "coordenadasFavoritas")
    }

    private func carregarFavoritos() {
        let salvos = UserDefaults.standard.stringArray(forKey: "coordenadasFavoritas") ?? []
        coordenadasFavoritas = Set(salvos)
    }
    
    /// Mede a escala do mapa (com ele parado) pra poder prever posições em qualquer zoom.
    private func calibrarEscala(camera: MapCamera, mapProxy: MapProxy) {
        // Só vale com a câmera olhando reto pra baixo e apontando pro norte
        let headingNorte = camera.heading < 1 || camera.heading > 359
        guard camera.pitch < 1, headingNorte, camera.distance > 0,
              let pontoCentro = mapProxy.convert(camera.centerCoordinate, to: .local),
              let acima = mapProxy.convert(CGPoint(x: pontoCentro.x, y: pontoCentro.y - 100), from: .local)
        else { return }

        let grausPorPonto = (acima.latitude - camera.centerCoordinate.latitude) / 100
        guard grausPorPonto > 0 else { return }

        grausPorPontoPorMetro = grausPorPonto / camera.distance
        yCentroDaCamera = pontoCentro.y
    }

    /*
     Calcula a câmera final de uma vez só: loja centralizada na horizontal e logo acima da sheet.
     Não depende de onde o mapa está agora (só do zoom de destino), então funciona igual vindo
     do toque no pin, da busca, dos recentes ou dos favoritos — e mesmo no meio de outra animação.
    */
    private func centralizarParaSheet(loja: Loja, zoomPadrao: Bool) {
        // Toque no pin mantém o zoom do usuário; busca/recentes/favoritos usam sempre o mesmo zoom
        let distanciaDesejada = zoomPadrao ? distanciaDeFoco : (cameraAtual?.distance ?? distanciaDeFoco)
        let distancia = min(max(distanciaDesejada, minimumZoom), maximumZoom)

        var centro = loja.coordinate
        if let grausPorPontoPorMetro, let yCentroDaCamera, alturaMapa > 0 {
            let yAlvo = max(alturaMapa - alturaSheetReduzida - espacamentoAcimaDaSheet, alturaMapa * 0.25)
            // Latitude diminui pra baixo: pra loja ficar abaixo do centro da câmera, o centro sobe
            centro.latitude = loja.latitude + (yAlvo - yCentroDaCamera) * grausPorPontoPorMetro * distancia
        }

        withAnimation(.easeInOut(duration: 0.8)) {
            cameraPosition = .camera(MapCamera(centerCoordinate: centro, distance: distancia, heading: 0, pitch: 0))
        }
    }

    /*
     O MapKit raramente devolve exatamente a mesma coordenada que cadastramos, então só a
     distância (40 m) deixava a loja passar como "local avulso" (pin vermelho embaixo do azul),
     ou casava com a vizinha errada (Pulga e Taberna ficam a ~20 m). Agora o nome tem prioridade.
    */
    private func lojaCadastradaCorrespondente(_ loja: Loja) -> Loja? {
        let alvo = CLLocation(latitude: loja.latitude, longitude: loja.longitude)
        let nomeAlvo = nomeNormalizado(loja.nameForSearch)

        let comDistancia = lojas.map { candidata in
            (loja: candidata,
             distancia: CLLocation(latitude: candidata.latitude, longitude: candidata.longitude).distance(from: alvo))
        }

        let porNome = comDistancia.filter { item in
            let nome = nomeNormalizado(item.loja.nameForSearch)
            let nomesBatem = !nome.isEmpty && !nomeAlvo.isEmpty
                && (nome.contains(nomeAlvo) || nomeAlvo.contains(nome))
            return nomesBatem && item.distancia < 500
        }
        if let melhor = porNome.min(by: { $0.distancia < $1.distancia }) {
            return melhor.loja
        }

        return comDistancia
            .filter { $0.distancia < 40 } // metros de tolerância
            .min(by: { $0.distancia < $1.distancia })?
            .loja
    }

    private func nomeNormalizado(_ nome: String) -> String {
        nome.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: .current)
            .filter { $0.isLetter || $0.isNumber }
    }

    private func zoomToFit(_ grupo: GroupOfShops) {
        let latitudes = grupo.lojas.map { $0.latitude }
        let longitudes = grupo.lojas.map { $0.longitude }

        guard let latMin = latitudes.min(), let latMax = latitudes.max(),
              let lonMin = longitudes.min(), let lonMax = longitudes.max() else { return }

        let centro = CLLocationCoordinate2D(
            latitude: (latMin + latMax) / 2,
            longitude: (lonMin + lonMax) / 2
        )

        let span = MKCoordinateSpan(
            latitudeDelta: max((latMax - latMin) * 2.2, 0.0015),
            longitudeDelta: max((lonMax - lonMin) * 2.2, 0.0015)
        )

        // Cálculo à parte, SÓ pra decidir se é um caso "sem solução por zoom" — não afeta a câmera
        let localizacoes = grupo.lojas.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }
        let localizacaoCentro = CLLocation(latitude: centro.latitude, longitude: centro.longitude)
        let raioMaximo = localizacoes.map { $0.distance(from: localizacaoCentro) }.max() ?? 0
        let distanciaEquivalente = raioMaximo * 3

        if distanciaEquivalente < minimumZoom {
            shopClusterManager.forcarSeparacao(grupo.lojas)
        }

        withAnimation(.easeInOut(duration: 1.6)) {
            cameraPosition = .region(MKCoordinateRegion(center: centro, span: span))
        }
    }
    
    //===============================================================================================
    private func setCameraWith(_ localization: CLLocationCoordinate2D?) {
        
        // Se a variável estiver vazia, seta como a região inteira e retorna
        guard let localization else {
            cameraPosition = .region(metropolyRegion)
            return
        }
        // Caso contrário, se estiver dentro da região, mostra a localização do usuário
        if metropolyRegion.isIn(localization) {
            cameraPosition = .userLocation(fallback: .region(metropolyRegion))
        } else {
            cameraPosition = .region(metropolyRegion)
        }
    }
    //===============================================================================================
}
//========================================================================================================

#Preview {
    RecifeMapView()
}
