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
    
    // Local guardado no UserDefaults (usado pelos recentes e pelos favoritos)
    struct LocalSalvo: Codable, Identifiable {
        let id: UUID
        let nome: String
        let latitude: Double
        let longitude: Double
        let endereco: String?
        // Nome da loja cadastrada (nil = local avulso). Loja cadastrada é identificada pelo
        // nome, e não pela coordenada, porque a coordenada pode ser atualizada pela internet.
        var lojaID: String? = nil
    }

    // Lojas cadastradas + locais avulsos favoritados
    private var favoritos: [Loja] {
        (lojas + locaisAvulsos).filter(ehFavorito)
    }

    // Lojas cadastradas + locais avulsos fixados
    private var fixados: [Loja] {
        (lojas + locaisAvulsos).filter(ehFixado)
    }

    /*
     Tudo que é desenhado como pin: o que o cluster deixou solto + o local selecionado que não
     está no cluster (resultado de busca). Uma lista só, com identidade estável, pra que
     favoritar/fixar o local selecionado só mude o visual do pin, sem tirar e recolocar ele
     no mapa (o que desfaria a seleção e fecharia a sheet).
    */
    private var pinsNoMapa: [Loja] {
        guard let pontoPesquisado, !shopClusterManager.visibleLojas.contains(pontoPesquisado) else {
            return shopClusterManager.visibleLojas
        }
        return shopClusterManager.visibleLojas + [pontoPesquisado]
    }
    
    // Lojas cadastradas "à mão". São gravadas no SwiftData na primeira abertura (sincronizarCatalogo)
    // e depois atualizadas pela internet a cada 20 dias (StoreSearch). O nome é o identificador
    // da loja; a coordenada daqui é a referência pra validar as atualizações.
    struct ItemDoCatalogo {
        let nome: String
        let latitude: Double
        let longitude: Double

        var coordenada: CLLocationCoordinate2D {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }

    private static let catalogoDeLojas: [ItemDoCatalogo] = [
        ItemDoCatalogo(nome: "R Vinil e CDs", latitude: -8.03734, longitude: -34.89216),
        ItemDoCatalogo(nome: "Vinil Alternativo", latitude: -8.06214, longitude: -34.88369),
        ItemDoCatalogo(nome: "Pulga Mercado de Discos", latitude: -8.03924, longitude: -34.89467),
        ItemDoCatalogo(nome: "Taberna do Vinil", latitude: -8.03940, longitude: -34.89471),
        ItemDoCatalogo(nome: "Bolacha Discos e Coisas", latitude: -8.04789, longitude: -34.89889),
        ItemDoCatalogo(nome: "Disco de Ouro", latitude: -8.06040, longitude: -34.88291),
        ItemDoCatalogo(nome: "Blackout Discos", latitude: -8.06003, longitude: -34.88234),
        ItemDoCatalogo(nome: "Flowers Records Brazil", latitude: -8.06222, longitude: -34.88272),
        ItemDoCatalogo(nome: "CD & Cia", latitude: -8.06209, longitude: -34.88209),
        ItemDoCatalogo(nome: "Sebo Pereira", latitude: -8.05799, longitude: -34.88632),
        ItemDoCatalogo(nome: "Praça do Sebo (Estandes Diversos)", latitude: -8.06306, longitude: -34.87872),
        ItemDoCatalogo(nome: "Fernando Vinil Discos", latitude: -8.04147, longitude: -34.89415),
        ItemDoCatalogo(nome: "Sebo da Torre", latitude: -8.04526, longitude: -34.90721)
    ]

    @Environment(\.modelContext) private var modelContext
    // Lojas cadastradas, já com as informações atualizadas
    @Query(sort: \Loja.nameForSearch) private var lojas: [Loja]
    
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
    
    @State private var recentesSalvos: [LocalSalvo] = []
    private let limiteDeRecentes = 15
    private func loja(de recente: LocalSalvo) -> Loja {
        let loja = Loja(
            nameForSearch: recente.nome,
            coordinate: CLLocationCoordinate2D(latitude: recente.latitude, longitude: recente.longitude)
        )
        loja.address = recente.endereco
        return loja
    }
    
    private func chave(para loja: Loja) -> String {
        lojas.contains(loja) ? "loja:\(loja.nameForSearch)" : "\(loja.latitude),\(loja.longitude)"
    }

    private func chave(de salvo: LocalSalvo) -> String {
        salvo.lojaID.map { "loja:\($0)" } ?? "\(salvo.latitude),\(salvo.longitude)"
    }

    // Nome da loja do catálogo que fica nessa coordenada (usado pra migrar favoritos antigos,
    // que eram identificados só pela coordenada)
    private func lojaDoCatalogo(latitude: Double, longitude: Double) -> String? {
        let alvo = CLLocation(latitude: latitude, longitude: longitude)
        return Self.catalogoDeLojas.first {
            CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: alvo) < 40
        }?.nome
    }
    
    // Zoom (graus de latitude visíveis na altura do mapa) usado ao abrir um local pela
    // busca, recentes ou favoritos
    private let spanDeFoco: CLLocationDegrees = 0.012

    @State private var favoritosSalvos: [LocalSalvo] = []
    @State private var fixadosSalvos: [LocalSalvo] = []
    // Uma instância fixa pra cada local avulso favoritado e/ou fixado (a seleção do Map
    // compara pela identidade da Loja). Entram no cluster junto com as lojas.
    @State private var locaisAvulsos: [Loja] = []
    // isPresented do .searchable: false fecha a busca de verdade (só tirar o foco deixava
    // a barra "ativa" e a animação ficava presa)
    @State private var buscaAtiva = false
    @State private var searchCompleter = SearchCompleter()
    @State private var textoBusca = ""
    @State private var pontoPesquisado: Loja?
    @State private var cameraPosition: MapCameraPosition
    @State private var shopClusterManager = ShopClusterManager()
    @State private var tarefaDeAtualizacao: Task<Void, Never>?
    @State private var lojaSelecionada: Loja?
    @State private var tamanhoMapa: CGSize = .zero
    // Região visível atualizada continuamente (inclusive durante animações), pra que as contas
    // de centralização batam com o que o MapProxy está enxergando naquele instante
    @State private var currentRegion: MKCoordinateRegion
    @State private var tarefaDeFoco: Task<Void, Never>?
    /*
     A sheet é controlada por lojaDaSheet, e não direto pela seleção do Map: ao tocar em outro
     pin, o Map passa por nil (desseleciona o atual e depois seleciona o novo). Com a sheet
     presa à seleção, isso fechava e reabria a sheet no meio da animação, e o iOS reabria em
     tela cheia. Agora a sheet fica aberta e só troca o conteúdo.
    */
    @State private var lojaDaSheet: Loja?
    @State private var tarefaDeFechamento: Task<Void, Never>?
    @State private var jaCentralizouNoUsuario = false
    // true quando a seleção veio da busca/recentes/favoritos (zoom padronizado, estilo Mapas do iPhone)
    @State private var selecaoVeioDaBusca = false
    // Detent atual da sheet: sempre volta pro reduzido ao selecionar uma loja
    @State private var detenteDaSheet: PresentationDetent
    @State private var tecladoVisivel = false
    @State private var confirmandoLimpezaDeRecentes = false
    private var locator = Locator()
    private let alturaSheetReduzida: CGFloat = 340
    private let espacamentoAcimaDaSheet: CGFloat = 40
    
    // Funciona basicamente como um constructor de RecifeMapView
    init() {
        _cameraPosition = State(initialValue: .userLocation(fallback: .region(metropolyRegion)))
        _currentRegion = State(initialValue: metropolyRegion)
        _detenteDaSheet = State(initialValue: .height(alturaSheetReduzida))
    }
    
    @State private var mapProxyAtual: MapProxy?

    var body: some View {
        NavigationStack {
            // Mapa ocupa a tela toda (passa por baixo da barra) e nunca muda de tamanho quando
            // a barra some/aparece ou o teclado abre
            mapaCompleto
                .ignoresSafeArea()
                .onGeometryChange(for: CGSize.self) { $0.size } action: { tamanhoMapa = $0 }
                .overlay {
                    ZStack {
                        if buscaAtiva {
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
                    .animation(.easeInOut(duration: 0.2), value: buscaAtiva)
                }
                .navigationTitle("Mapa")
                .navigationBarTitleDisplayMode(.inline)
                // Com a sheet aberta não dá pra pesquisar: a barra (título + busca) some
                .toolbarVisibility(lojaDaSheet == nil ? .visible : .hidden, for: .navigationBar)
                .searchable(
                    text: $textoBusca,
                    isPresented: $buscaAtiva,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Buscar local"
                )
                .onSubmit(of: .search) {
                    if let primeira = searchCompleter.sugestoes.first {
                        selecionarSugestao(primeira)
                    }
                }
        }
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

    private func fecharBusca() {
        textoBusca = ""
        searchCompleter.limpar()
        buscaAtiva = false
    }

    // Busca vazia: fixados e favoritos em rolagem lateral, recentes em lista, sobre fundo desfocado
    private var searchOverlay: some View {
        List {
            if !fixados.isEmpty {
                Section {
                    carrossel(fixados, textoRemover: "Desafixar", iconeRemover: "pin.slash",
                              remover: alternarFixado)
                } header: {
                    cabecalho("Fixados")
                }
                .headerProminence(.increased)
            }

            if !favoritos.isEmpty {
                Section {
                    carrossel(favoritos, textoRemover: "Remover dos Favoritos", iconeRemover: "star.slash",
                              remover: alternarFavorito)
                } header: {
                    cabecalho("Favoritos")
                }
                .headerProminence(.increased)
            }

            if !recentesSalvos.isEmpty {
                Section {
                    ForEach(recentesSalvos) { recente in
                        linhaDeLocal(titulo: Text(recente.nome), subtitulo: recente.endereco,
                                     estilo: estilo(paraRecente: recente)) {
                            selecionarLojaDaBusca(loja(de: recente))
                        }
                        .listRowBackground(Color.clear)
                    }
                    .onDelete(perform: removerRecentes)
                } header: {
                    HStack {
                        cabecalho("Recentes")
                        Spacer()
                        Button("Limpar") {
                            confirmandoLimpezaDeRecentes = true
                        }
                        .font(.subheadline)
                        .textCase(nil)
                    }
                }
                .headerProminence(.increased)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(.ultraThinMaterial)
        .scrollDismissesKeyboard(.immediately)
        .overlay {
            if fixados.isEmpty && favoritos.isEmpty && recentesSalvos.isEmpty {
                ContentUnavailableView(
                    "Busque lojas e lugares",
                    systemImage: "magnifyingglass",
                    description: Text("Seus locais fixados, favoritos e buscas recentes aparecem aqui.")
                )
            }
        }
        // Alerta centralizado (a confirmationDialog abria como folha presa à barra)
        .alert("Limpar buscas recentes?", isPresented: $confirmandoLimpezaDeRecentes) {
            Button("Limpar", role: .destructive) {
                limparRecentes()
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Essa ação não pode ser desfeita.")
        }
    }

    // Resultados enquanto digita: lista simples, com o trecho digitado em destaque
    private var suggestionsList: some View {
        List(searchCompleter.sugestoes, id: \.self) { sugestao in
            linhaDeLocal(titulo: tituloDestacado(sugestao), subtitulo: sugestao.subtitle,
                         estilo: estilo(paraSugestao: sugestao)) {
                selecionarSugestao(sugestao)
            }
            .listRowBackground(Color.clear)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(.ultraThinMaterial)
        .scrollDismissesKeyboard(.immediately)
    }

    // Título de seção em destaque (como no app Mapas): cor primária do sistema, que se adapta
    // ao modo claro/escuro. Color.primary (e não o estilo .primary) pra o fundo desfocado não
    // deixar o texto acinzentado.
    private func cabecalho(_ titulo: String) -> some View {
        Text(titulo)
            .font(.title3.bold())
            .foregroundStyle(Color.primary)
            .textCase(nil)
    }

    // Fixados/favoritos: ícones grandes em rolagem lateral. Pra remover, toque longo
    // (menu de contexto), já que deslizar pro lado conflita com a rolagem horizontal.
    private func carrossel(_ locais: [Loja], textoRemover: String, iconeRemover: String,
                           remover: @escaping (Loja) -> Void) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 16) {
                ForEach(locais) { loja in
                    let estilo = estilo(para: loja)
                    Button {
                        selecionarLojaDaBusca(loja)
                    } label: {
                        VStack(spacing: 6) {
                            IconeDeLocal(cor: estilo.cor, icone: estilo.icone, corDoIcone: estilo.corDoIcone,
                                         formato: estilo.formato, claro: estilo.claro, tamanho: 56)
                            Text(nomeDeExibicao(loja))
                                .font(.caption)
                                .foregroundStyle(.primary)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .frame(width: 72)
                        }
                    }
                    .buttonStyle(.plain)
                    .contextMenu {
                        Button(textoRemover, systemImage: iconeRemover) {
                            remover(loja)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    private func linhaDeLocal(titulo: Text, subtitulo: String?, estilo: EstiloDeLocal,
                              acao: @escaping () -> Void) -> some View {
        Button(action: acao) {
            HStack(spacing: 12) {
                IconeDeLocal(cor: estilo.cor, icone: estilo.icone, corDoIcone: estilo.corDoIcone,
                             formato: estilo.formato, claro: estilo.claro)

                VStack(alignment: .leading, spacing: 2) {
                    titulo
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    if let subtitulo, !subtitulo.isEmpty {
                        Text(subtitulo)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
        }
        .foregroundStyle(.primary)
    }

    // Deixa em negrito a parte do título que bate com o que foi digitado (igual ao Mapas)
    private func tituloDestacado(_ sugestao: MKLocalSearchCompletion) -> Text {
        var titulo = AttributedString(sugestao.title)
        for valor in sugestao.titleHighlightRanges {
            if let intervalo = Range(valor.rangeValue, in: titulo) {
                titulo[intervalo].font = .body.weight(.semibold)
            }
        }
        return Text(titulo)
    }

    private func nomeDeExibicao(_ loja: Loja) -> String {
        loja.officialName ?? loja.nameForSearch
    }

    private func removerRecentes(em indices: IndexSet) {
        recentesSalvos.remove(atOffsets: indices)
        salvarRecentes()
    }

    private func limparRecentes() {
        recentesSalvos.removeAll()
        salvarRecentes()
    }

    //===============================================================================================
    /**
     =================================================================================
     Faz o mapa mostrar a "Principal" Região Metropolitana do Recife  e "prende" o usuário nela.
     =================================================================================
     **/
    // Pin pronto pra desenhar: loja + visual já calculado
    private struct PinDesenhado: Identifiable {
        let loja: Loja
        let visual: PinDoMapa
        var id: Loja.ID { loja.id }
    }

    private var mapaCompleto: some View {
        /*
         Os visuais são calculados AQUI, no body, e não dentro do ForEach/Annotation do Map:
         aqueles closures rodam depois, fora do body, e o SwiftUI não acompanha o @State lido
         lá dentro (favoritos, fixados, seleção). O pin ficava com o visual antigo.
        */
        let pinsDesenhados = pinsNoMapa.map { PinDesenhado(loja: $0, visual: pin(para: $0)) }

        return MapReader { mapProxy in
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

                // Lojas, favoritos/fixados avulsos e o local pesquisado, todos com o mesmo pin
                ForEach(pinsDesenhados) { pin in
                    let loja = pin.loja
                    Annotation(loja.nameForSearch, coordinate: loja.coordinate, anchor: .bottom) {
                        pin.visual
                    }
                    // Sem a tag o Map não reconhece o pin como selecionado
                    .tag(loja)
                }

                ForEach(shopClusterManager.visibleGroups) { group in
                    Annotation("", coordinate: group.coordinate) {
                        BolhaDeAgrupamento(quantidade: group.count)
                        .onTapGesture {
                            fecharSheetAntes {
                                zoomToFit(group)
                            }
                        }
                    }
                }
                
            }
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
            .onMapCameraChange(frequency: .continuous) { context in
                currentRegion = context.region
            }
            .onMapCameraChange(frequency: .onEnd) { context in
                currentRegion = context.region
                searchCompleter.atualizarRegiao(context.region)
                shopClusterManager.limparForcadosSeAfastado(distanciaAtual: context.camera.distance)
                agendarAtualizacaoDosClusters(mapProxy: mapProxy)
            }
            .onChange(of: lojaSelecionada) { _, novaLoja in
                tarefaDeFechamento?.cancel()

                guard let loja = novaLoja else {
                    // Pode ser só a passagem por nil na troca de pin: só fecha se continuar sem seleção
                    tarefaDeFechamento = Task {
                        try? await Task.sleep(for: .milliseconds(200))
                        guard !Task.isCancelled, lojaSelecionada == nil else { return }
                        limparSelecao(mapProxy: mapProxy)
                    }
                    return
                }

                let sheetEstavaFechada = lojaDaSheet == nil
                if sheetEstavaFechada {
                    // Só mexe no detent antes de apresentar; com a sheet aberta, mantém como está
                    detenteDaSheet = .height(alturaSheetReduzida)
                }
                lojaDaSheet = loja

                let veioDaBusca = selecaoVeioDaBusca
                selecaoVeioDaBusca = false
                // Se a sheet estava fechada, a barra vai sumir agora; espera ela sumir pra medir
                // o mapa já no estado final (o MapKit reenquadra quando a área útil muda)
                focar(loja, mapProxy: mapProxy, zoomPadrao: veioDaBusca, aguardarBarra: sheetEstavaFechada)
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
                sincronizarCatalogo()
                carregarRecentes()
                carregarFavoritosEFixados()
                shopClusterManager.setLojas(lojas + locaisAvulsos)
                await shopClusterManager.updateClusters(mapProxy: mapProxy)
                await atualizarLojasPelaInternet(mapProxy: mapProxy)
            }
            // Na primeira abertura as lojas só aparecem na @Query depois de gravadas
            .onChange(of: lojas) {
                shopClusterManager.setLojas(lojas + locaisAvulsos)
                agendarAtualizacaoDosClusters(mapProxy: mapProxy)
            }
            .onAppear {
                locator.requestLocation()
                mapProxyAtual = mapProxy
            }
            .sheet(isPresented: sheetAberta, onDismiss: {
                detenteDaSheet = .height(alturaSheetReduzida)
            }) {
                if let loja = lojaDaSheet {
                    LojaDetailView(
                        loja: loja,
                        ehFavorito: ehFavorito(loja),
                        onToggleFavorito: { alternarFavorito(loja) },
                        ehFixado: ehFixado(loja),
                        onToggleFixado: { alternarFixado(loja) }
                    )
                    .presentationDetents([.height(alturaSheetReduzida), .large], selection: $detenteDaSheet)
                    .presentationDragIndicator(.visible)
                    .presentationBackgroundInteraction(.enabled(upThrough: .height(alturaSheetReduzida)))
                    #if DEBUG
                    .onAppear {
                        print("[Sheet] abriu: \(loja.nameForSearch) | detent: \(detenteDaSheet == .large ? "large" : "reduzida") | teclado: \(tecladoVisivel)")
                    }
                    .onChange(of: detenteDaSheet) { antigo, novo in
                        print("[Sheet] detent mudou: \(antigo == .large ? "large" : "reduzida") -> \(novo == .large ? "large" : "reduzida")")
                    }
                    #endif
                }
            }
        }
    }
    
    private var sheetAberta: Binding<Bool> {
        Binding(
            get: { lojaDaSheet != nil },
            set: { aberta in
                // Usuário fechou a sheet arrastando pra baixo
                guard !aberta else { return }
                lojaDaSheet = nil
                lojaSelecionada = nil
            }
        )
    }

    /*
     Tocar em algo que não é pin de loja (ex: um cluster) fecha a sheet primeiro e só depois
     executa a ação, pra câmera não se mover com a sheet ainda cobrindo o mapa.
    */
    private func fecharSheetAntes(_ acao: @escaping () -> Void) {
        guard lojaDaSheet != nil else {
            acao()
            return
        }

        tarefaDeFechamento?.cancel()
        lojaSelecionada = nil
        if let mapProxyAtual {
            limparSelecao(mapProxy: mapProxyAtual)
        } else {
            lojaDaSheet = nil
        }

        Task {
            // Tempo da animação de fechamento da sheet
            try? await Task.sleep(for: .milliseconds(350))
            acao()
        }
    }

    private func limparSelecao(mapProxy: MapProxy) {
        tarefaDeFoco?.cancel()
        lojaDaSheet = nil
        // Reseta com a sheet fechada: mudar o detent no meio da apresentação às vezes é ignorado
        detenteDaSheet = .height(alturaSheetReduzida)
        pontoPesquisado = nil
        shopClusterManager.destacar(nil)
        agendarAtualizacaoDosClusters(mapProxy: mapProxy)
    }

    // Grava no SwiftData as lojas do catálogo que ainda não estão lá (e remove as que saíram)
    private func sincronizarCatalogo() {
        let existentes = (try? modelContext.fetch(FetchDescriptor<Loja>())) ?? []
        let nomesDoCatalogo = Set(Self.catalogoDeLojas.map(\.nome))
        var nomesGravados = Set<String>()

        for loja in existentes {
            // Remove lojas que saíram do catálogo e duplicadas
            if !nomesDoCatalogo.contains(loja.nameForSearch) || !nomesGravados.insert(loja.nameForSearch).inserted {
                modelContext.delete(loja)
            }
        }

        for item in Self.catalogoDeLojas where !nomesGravados.contains(item.nome) {
            modelContext.insert(Loja(nameForSearch: item.nome, coordinate: item.coordenada))
        }

        // Salva já: o ID de um objeto recém-inserido é temporário e muda no save, o que
        // quebraria a seleção e os clusters (Loja é comparada pelo persistentModelID)
        try? modelContext.save()
    }

    // Busca na internet as lojas que não são atualizadas há 20 dias (coordenada, nome, contato...)
    private func atualizarLojasPelaInternet(mapProxy: MapProxy) async {
        let busca = StoreSearch()
        let referencias = Dictionary(uniqueKeysWithValues: Self.catalogoDeLojas.map { ($0.nome, $0.coordenada) })
        // Busca direto no contexto: na primeira abertura a @Query ainda pode estar vazia aqui
        let lojasGravadas = (try? modelContext.fetch(FetchDescriptor<Loja>())) ?? []

        var mudouAlgo = false
        for loja in lojasGravadas {
            guard let referencia = referencias[loja.nameForSearch] else { continue }
            if await busca.atualizar(loja, referencia: referencia) {
                mudouAlgo = true
            }
        }

        guard mudouAlgo else { return }
        try? modelContext.save()
        // Coordenadas podem ter mudado: refaz os clusters
        shopClusterManager.setLojas(lojas + locaisAvulsos)
        agendarAtualizacaoDosClusters(mapProxy: mapProxy)
    }

    private func registrarRecente(_ loja: Loja) {
        guard loja.latitude != 0, loja.longitude != 0 else { return }

        recentesSalvos.removeAll {
            $0.latitude == loja.latitude && $0.longitude == loja.longitude
        }

        let novoRecente = LocalSalvo(
            id: UUID(),
            nome: loja.nameForSearch,
            latitude: loja.latitude,
            longitude: loja.longitude,
            endereco: loja.address
        )

        recentesSalvos.insert(novoRecente, at: 0)
        if recentesSalvos.count > limiteDeRecentes {
            recentesSalvos.removeLast(recentesSalvos.count - limiteDeRecentes)
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
              let decodificado = try? JSONDecoder().decode([LocalSalvo].self, from: dados) else { return }
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

        if let original = lojaCadastradaCorrespondente(candidata)
            ?? correspondente(candidata, em: locaisAvulsos) {
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
        abrir(lojaCadastradaCorrespondente(loja) ?? correspondente(loja, em: locaisAvulsos) ?? loja)
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
                if let mapProxyAtual { focar(loja, mapProxy: mapProxyAtual, zoomPadrao: true, aguardarBarra: false) }
            } else {
                selecaoVeioDaBusca = true
                lojaSelecionada = loja
            }
        }
    }

    private func focar(_ loja: Loja, mapProxy: MapProxy, zoomPadrao: Bool, aguardarBarra: Bool) {
        let cadastrada = lojas.contains(loja)
        let avulsoSalvo = locaisAvulsos.contains(loja)
        // Local de busca (não cadastrado) fica em pontoPesquisado enquanto estiver selecionado
        pontoPesquisado = cadastrada ? nil : loja
        // O selecionado nunca fica escondido dentro de um cluster
        shopClusterManager.destacar(loja)
        agendarAtualizacaoDosClusters(mapProxy: mapProxy)
        // Toque no pin mantém o zoom do usuário; busca/recentes/favoritos (ou local avulso)
        // sempre vão pro mesmo zoom, aproximando ou afastando conforme o necessário
        // (pin amarelo já está no mapa, então tocar nele se comporta como tocar numa loja)
        let usarZoomPadrao = zoomPadrao || !(cadastrada || avulsoSalvo)

        // Uma centralização por vez: toques rápidos cancelam a anterior
        tarefaDeFoco?.cancel()
        tarefaDeFoco = Task {
            if aguardarBarra {
                try? await Task.sleep(for: .milliseconds(300))
            }
            guard !Task.isCancelled, loja == lojaSelecionada else { return }
            centralizarParaSheet(loja: loja, mapProxy: mapProxy, zoomPadrao: usarZoomPadrao)
        }
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
        let chaveLoja = chave(para: loja)
        return favoritosSalvos.contains { chave(de: $0) == chaveLoja }
    }

    private func ehFixado(_ loja: Loja) -> Bool {
        let chaveLoja = chave(para: loja)
        return fixadosSalvos.contains { chave(de: $0) == chaveLoja }
    }

    private func alternarFavorito(_ loja: Loja) {
        alternar(loja, em: &favoritosSalvos)
        salvar(favoritosSalvos, chave: "favoritosSalvos")
        atualizarLocaisAvulsos(mudou: loja)
    }

    private func alternarFixado(_ loja: Loja) {
        alternar(loja, em: &fixadosSalvos)
        salvar(fixadosSalvos, chave: "fixadosSalvos")
        atualizarLocaisAvulsos(mudou: loja)
    }

    private func alternar(_ loja: Loja, em lista: inout [LocalSalvo]) {
        let chaveLoja = chave(para: loja)
        if lista.contains(where: { chave(de: $0) == chaveLoja }) {
            lista.removeAll { chave(de: $0) == chaveLoja }
        } else {
            lista.append(LocalSalvo(
                id: UUID(),
                nome: loja.officialName ?? loja.nameForSearch,
                latitude: loja.latitude,
                longitude: loja.longitude,
                endereco: loja.address,
                lojaID: lojas.contains(loja) ? loja.nameForSearch : nil
            ))
        }
    }

    // Mantém locaisAvulsos = avulsos que são favoritos e/ou fixados, e manda pro cluster
    private func atualizarLocaisAvulsos(mudou loja: Loja) {
        guard !lojas.contains(loja) else { return }

        let deveFicar = ehFavorito(loja) || ehFixado(loja)
        if deveFicar, !locaisAvulsos.contains(loja) {
            // Usa a mesma instância que está selecionada, pro pin só mudar de visual
            locaisAvulsos.append(loja)
        } else if !deveFicar {
            // Se estiver selecionado, continua no mapa como pontoPesquisado (volta a ser vermelho)
            locaisAvulsos.removeAll { $0 == loja }
        }

        shopClusterManager.setLojas(lojas + locaisAvulsos)
        if let mapProxyAtual {
            agendarAtualizacaoDosClusters(mapProxy: mapProxyAtual)
        }
    }

    private func salvar(_ lista: [LocalSalvo], chave: String) {
        if let dados = try? JSONEncoder().encode(lista) {
            UserDefaults.standard.set(dados, forKey: chave)
        }
    }

    private func carregarLista(chave: String) -> [LocalSalvo]? {
        guard let dados = UserDefaults.standard.data(forKey: chave) else { return nil }
        return try? JSONDecoder().decode([LocalSalvo].self, from: dados)
    }

    private func carregarFavoritosEFixados() {
        if let salvos = carregarLista(chave: "favoritosSalvos") {
            favoritosSalvos = salvos
        } else {
            migrarFavoritosAntigos()
        }
        fixadosSalvos = carregarLista(chave: "fixadosSalvos") ?? []

        // Favoritos/fixados salvos antes de existir lojaID: descobre pela coordenada se é loja
        let migrouFavoritos = identificarLojas(em: &favoritosSalvos)
        let migrouFixados = identificarLojas(em: &fixadosSalvos)
        if migrouFavoritos { salvar(favoritosSalvos, chave: "favoritosSalvos") }
        if migrouFixados { salvar(fixadosSalvos, chave: "fixadosSalvos") }

        // Uma Loja fixa por local avulso (sem repetir quem é favorito E fixado)
        var vistos = Set<String>()
        locaisAvulsos = (favoritosSalvos + fixadosSalvos).compactMap { salvo in
            guard salvo.lojaID == nil, vistos.insert(chave(de: salvo)).inserted else { return nil }
            return loja(de: salvo)
        }
    }

    // Versão antiga guardava só "lat,lon"; recupera o nome pelas lojas ou pelos recentes
    // Retorna true se alguma entrada foi atualizada
    private func identificarLojas(em lista: inout [LocalSalvo]) -> Bool {
        var mudou = false
        for indice in lista.indices where lista[indice].lojaID == nil {
            if let nome = lojaDoCatalogo(latitude: lista[indice].latitude, longitude: lista[indice].longitude) {
                lista[indice].lojaID = nome
                mudou = true
            }
        }
        return mudou
    }

    private func migrarFavoritosAntigos() {
        let antigas = UserDefaults.standard.stringArray(forKey: "coordenadasFavoritas") ?? []
        guard !antigas.isEmpty else { return }

        favoritosSalvos = antigas.compactMap { chaveAntiga in
            let partes = chaveAntiga.split(separator: ",").compactMap { Double($0) }
            guard partes.count == 2 else { return nil }
            let nomeDaLoja = lojaDoCatalogo(latitude: partes[0], longitude: partes[1])
            let recente = recentesSalvos.first { chave(de: $0) == chaveAntiga }
            return LocalSalvo(
                id: UUID(),
                nome: nomeDaLoja ?? recente?.nome ?? "Local favorito",
                latitude: partes[0],
                longitude: partes[1],
                endereco: recente?.endereco,
                lojaID: nomeDaLoja
            )
        }
        salvar(favoritosSalvos, chave: "favoritosSalvos")
        UserDefaults.standard.removeObject(forKey: "coordenadasFavoritas")
    }

    /*
     Visual de cada pin:
      - loja cadastrada: quadrado marrom com vitrine (+ selo de estrela se favorita, ou de alfinete se fixada)
      - local avulso favorito: mostarda com brilho dourado e estrela creme (+ selo de alfinete se também fixado)
      - local avulso só fixado: vinho com alfinete
      - resultado de busca (não salvo): vinho desbotado
    */
    // Cores da paleta do app (Paleta.swift). Símbolo sempre creme; o favorito é "claro" (sem tons escuros).
    private struct EstiloDeLocal {
        let cor: Color
        let icone: String
        var corDoIcone: Color = .creme
        var claro = false
        var formato: PinDoMapa.Formato = .circulo
        var selo: PinDoMapa.Selo? = nil
    }

    private func estilo(para loja: Loja) -> EstiloDeLocal {
        let favorito = ehFavorito(loja)
        let fixado = ehFixado(loja)
        let seloEstrela = PinDoMapa.Selo(icone: "star.fill", cor: .mostarda, claro: true)
        let seloAlfinete = PinDoMapa.Selo(icone: "pin.fill", cor: .vinho)

        if lojas.contains(loja) {
            return EstiloDeLocal(cor: .marrom, icone: "storefront", formato: .retangulo,
                                 selo: favorito ? seloEstrela : (fixado ? seloAlfinete : nil))
        }
        if favorito {
            return EstiloDeLocal(cor: .mostarda, icone: "star.fill", claro: true,
                                 selo: fixado ? seloAlfinete : nil)
        }
        if fixado {
            return EstiloDeLocal(cor: .vinho, icone: "pin.fill")
        }
        // Local não salvo: vinho desbotado, mais discreto que os salvos
        return EstiloDeLocal(cor: .vinhoSuave, icone: "mappin")
    }

    // Recente de loja cadastrada usa o ícone da loja; os demais, o relógio
    private func estilo(paraRecente recente: LocalSalvo) -> EstiloDeLocal {
        let posicao = CLLocation(latitude: recente.latitude, longitude: recente.longitude)
        let ehLoja = lojas.contains {
            $0.nameForSearch.pareceONomeDe(recente.nome)
                && CLLocation(latitude: $0.latitude, longitude: $0.longitude).distance(from: posicao) < 500
        }
        return ehLoja
            ? EstiloDeLocal(cor: .marrom, icone: "storefront", formato: .retangulo)
            : EstiloDeLocal(cor: .cinzaEscuro, icone: "clock.fill")
    }

    // Sugestão sem subtítulo é uma busca por termo ("vinil"); com subtítulo é um lugar
    private func estilo(paraSugestao sugestao: MKLocalSearchCompletion) -> EstiloDeLocal {
        if sugestao.subtitle.isEmpty {
            return EstiloDeLocal(cor: .cinzaEscuro, icone: "magnifyingglass")
        }
        if lojas.contains(where: { $0.nameForSearch.pareceONomeDe(sugestao.title) }) {
            return EstiloDeLocal(cor: .marrom, icone: "storefront", formato: .retangulo)
        }
        return EstiloDeLocal(cor: .vinhoSuave, icone: "mappin")
    }

    private func pin(para loja: Loja) -> PinDoMapa {
        let estilo = estilo(para: loja)
        return PinDoMapa(cor: estilo.cor, icone: estilo.icone, corDoIcone: estilo.corDoIcone,
                         formato: estilo.formato, claro: estilo.claro, selo: estilo.selo,
                         selecionado: loja == lojaSelecionada)
    }

    /*
     Mesma ideia da versão original (que funcionava bem no toque no pin): tudo é medido no
     próprio mapa, no estado atual, com o MapProxy.
      1. Pega a coordenada que está no ponto-alvo da tela (logo acima da sheet).
      2. A diferença entre ela e o centro da região é "quanto o centro precisa ficar
         deslocado da loja" no zoom atual.
      3. Esse deslocamento escala linearmente com o zoom, então pra ir pro zoom padrão
         basta multiplicar pela proporção entre o span novo e o atual.
     No toque no pin (zoom mantido) a proporção é 1 e a conta é idêntica à original.
    */
    private func centralizarParaSheet(loja: Loja, mapProxy: MapProxy, zoomPadrao: Bool) {
        let regiao = currentRegion
        guard tamanhoMapa.height > 0, regiao.span.latitudeDelta > 0,
              let pontoCentro = mapProxy.convert(regiao.center, to: .local) else { return }

        let pontoLoja = mapProxy.convert(loja.coordinate, to: .local)
        let lojaNaTela = pontoLoja.map {
            $0.x >= 0 && $0.x <= tamanhoMapa.width && $0.y >= 0 && $0.y <= tamanhoMapa.height
        } ?? false

        // Toque num pin visível: mantém zoom e posição horizontal (comportamento original).
        // Busca/recentes/favoritos ou loja fora da tela: zoom padrão e centralizado na horizontal.
        let manterZoom = !zoomPadrao && lojaNaTela
        let proporcao = manterZoom ? 1 : spanDeFoco / regiao.span.latitudeDelta
        let xAlvo = manterZoom ? (pontoLoja?.x ?? pontoCentro.x) : pontoCentro.x
        let yAlvo = max(tamanhoMapa.height - alturaSheetReduzida - espacamentoAcimaDaSheet,
                        tamanhoMapa.height * 0.25)

        guard let coordenadaNoAlvo = mapProxy.convert(CGPoint(x: xAlvo, y: yAlvo), from: .local) else { return }

        let deslocamentoLat = (coordenadaNoAlvo.latitude - regiao.center.latitude) * proporcao
        let deslocamentoLon = (coordenadaNoAlvo.longitude - regiao.center.longitude) * proporcao

        let novoCentro = CLLocationCoordinate2D(
            latitude: loja.latitude - deslocamentoLat,
            longitude: loja.longitude - deslocamentoLon
        )
        // Mantém a proporção largura/altura da região visível, pra ela caber exatamente na tela
        let novoSpan = MKCoordinateSpan(
            latitudeDelta: regiao.span.latitudeDelta * proporcao,
            longitudeDelta: regiao.span.longitudeDelta * proporcao
        )

        withAnimation(.easeInOut(duration: manterZoom ? 0.6 : 0.8)) {
            cameraPosition = .region(MKCoordinateRegion(center: novoCentro, span: novoSpan))
        }
    }

    /*
     O MapKit raramente devolve exatamente a mesma coordenada que cadastramos, então só a
     distância (40 m) deixava a loja passar como "local avulso" (pin vermelho embaixo do azul),
     ou casava com a vizinha errada (Pulga e Taberna ficam a ~20 m). Agora o nome tem prioridade.
    */
    private func lojaCadastradaCorrespondente(_ loja: Loja) -> Loja? {
        correspondente(loja, em: lojas)
    }

    private func correspondente(_ loja: Loja, em candidatas: [Loja]) -> Loja? {
        let alvo = CLLocation(latitude: loja.latitude, longitude: loja.longitude)

        let comDistancia = candidatas.map { candidata in
            (loja: candidata,
             distancia: CLLocation(latitude: candidata.latitude, longitude: candidata.longitude).distance(from: alvo))
        }

        let porNome = comDistancia.filter { item in
            item.loja.nameForSearch.pareceONomeDe(loja.nameForSearch) && item.distancia < 500
        }
        if let melhor = porNome.min(by: { $0.distancia < $1.distancia }) {
            return melhor.loja
        }

        return comDistancia
            .filter { $0.distancia < 40 } // metros de tolerância
            .min(by: { $0.distancia < $1.distancia })?
            .loja
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
        .modelContainer(for: appSchema, inMemory: true)
}
