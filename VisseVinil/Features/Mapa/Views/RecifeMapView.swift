//
//  RecifeMapView.swift
//  VisseVinil
//
//  Created by Gabriel Alves Gadelha de Melo on 11/09/26.
//

import SwiftUI
import MapKit
import SwiftData

/*
 Tela do mapa: junta as peças e cuida do fluxo de seleção.
  - Mapa com pins (lojas, favoritos/fixados avulsos e o local pesquisado) e agrupamentos
  - Busca (BuscaVaziaView / SugestoesDeBuscaView)
  - Sheet de detalhes do local selecionado (LojaDetailView)
 As regras ficam fora da tela: locais salvos (LocaisSalvosStore), lojas
 (SincronizacaoDeLojas), contas de câmera (EnquadramentoDoMapa), correspondência entre
 locais (CorrespondenciaDeLocais) e visual dos pins (EstiloDeLocal).
*/
struct RecifeMapView: View {
    private typealias Config = ConfiguracaoDoMapa

    @Environment(\.modelContext) private var modelContext
    // Lojas cadastradas, já com as informações atualizadas
    @Query(sort: \Loja.nameForSearch) private var lojas: [Loja]

    @State private var locaisSalvos = LocaisSalvosStore()
    @State private var shopClusterManager = ShopClusterManager()
    @State private var searchCompleter = SearchCompleter()
    @State private var locator = Locator()

    // MARK: Preferências (salvas no aparelho)
    @AppStorage("mapa.exibicaoDosLocais") private var exibicao: ExibicaoDosLocais = .agrupados

    // MARK: Câmera
    @State private var cameraPosition: MapCameraPosition =
        .userLocation(fallback: .region(ConfiguracaoDoMapa.regiaoMetropolitana))
    // Região visível atualizada continuamente (inclusive durante animações), pra que as contas
    // de centralização batam com o que o MapProxy está enxergando naquele instante
    @State private var currentRegion = ConfiguracaoDoMapa.regiaoMetropolitana
    @State private var tamanhoMapa: CGSize = .zero
    @State private var mapProxyAtual: MapProxy?
    @State private var jaCentralizouNoUsuario = false
    // Escopo compartilhado entre o Map e os botões de localização/bússola fora dele
    @Namespace private var escopoDoMapa

    // MARK: Busca
    // isPresented do .searchable: false fecha a busca de verdade (só tirar o foco deixava
    // a barra "ativa" e a animação ficava presa)
    @State private var buscaAtiva = false
    @State private var textoBusca = ""
    @State private var tecladoVisivel = false

    // MARK: Seleção e sheet
    @State private var lojaSelecionada: Loja?
    // Local de busca (não cadastrado) que está selecionado: vira pin enquanto estiver
    @State private var pontoPesquisado: Loja?
    /*
     A sheet é controlada por lojaDaSheet, e não direto pela seleção do Map: ao tocar em outro
     pin, o Map passa por nil (desseleciona o atual e depois seleciona o novo). Com a sheet
     presa à seleção, isso fechava e reabria a sheet no meio da animação, e o iOS reabria em
     tela cheia. Agora a sheet fica aberta e só troca o conteúdo.
    */
    @State private var lojaDaSheet: Loja?
    // Detent atual da sheet: sempre volta pro reduzido ao selecionar uma loja
    @State private var detenteDaSheet: PresentationDetent = .height(ConfiguracaoDoMapa.alturaDaSheetReduzida)
    // true quando a seleção veio da busca/recentes/favoritos (zoom padronizado, estilo Mapas do iPhone)
    @State private var selecaoVeioDaBusca = false

    // MARK: Tarefas (canceladas quando uma nova começa)
    @State private var tarefaDeAtualizacao: Task<Void, Never>?
    @State private var tarefaDeFoco: Task<Void, Never>?
    @State private var tarefaDeFechamento: Task<Void, Never>?

    private var detenteReduzido: PresentationDetent {
        .height(Config.alturaDaSheetReduzida)
    }

    var body: some View {
        NavigationStack {
            // Mapa ocupa a tela toda (passa por baixo da barra) e nunca muda de tamanho quando
            // a barra some/aparece ou o teclado abre
            mapa
                .ignoresSafeArea()
                .onGeometryChange(for: CGSize.self) { $0.size } action: { tamanhoMapa = $0 }
                // Rastreio + bússola: o botão de localização alterna entre seguir o usuário e
                // seguir com a direção do aparelho (o "farol" de para onde o celular aponta).
                // Logo abaixo, o botão que alterna como os locais aparecem (mesmo tamanho e ideia)
                .overlay(alignment: .topTrailing) {
                    if !buscaAtiva {
                        VStack(spacing: 10) {
                            MapUserLocationButton(scope: escopoDoMapa)
                            BotaoDeExibicaoDosLocais(exibicao: $exibicao)
                            MapCompass(scope: escopoDoMapa)
                        }
                        .buttonBorderShape(.circle)
                        .padding(.trailing, 12)
                        .padding(.top, 8)
                    }
                }
                .mapScope(escopoDoMapa)
                .overlay {
                    ZStack {
                        if buscaAtiva {
                            telaDaBusca
                                .transition(.opacity)
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: buscaAtiva)
                }
                .navigationTitle("Lojas")
                .navigationBarTitleDisplayMode(.inline)
                // Com a sheet aberta não dá pra pesquisar: a barra (título + busca) some
                .toolbarVisibility(lojaDaSheet == nil ? .visible : .hidden, for: .navigationBar)
                .searchable(
                    text: $textoBusca,
                    isPresented: $buscaAtiva,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Buscar lojas de vinil"
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

    // MARK: - Busca

    @ViewBuilder
    private var telaDaBusca: some View {
        if textoBusca.isEmpty {
            BuscaVaziaView(locaisSalvos: locaisSalvos, selecionar: selecionarLocalSalvo)
        } else {
            SugestoesDeBuscaView(sugestoes: searchCompleter.sugestoes, lojasCadastradas: lojas,
                                 selecionar: selecionarSugestao)
        }
    }

    private func fecharBusca() {
        textoBusca = ""
        searchCompleter.limpar()
        buscaAtiva = false
    }

    private func selecionarSugestao(_ sugestao: MKLocalSearchCompletion) {
        Task {
            let pedido = MKLocalSearch.Request(completion: sugestao)
            // Busca falhou: não faz nada (a sugestão continua na lista)
            guard let item = try? await MKLocalSearch(request: pedido).start().mapItems.first else { return }
            selecionarResultado(item)
        }
    }

    private func selecionarResultado(_ item: MKMapItem) {
        let candidata = Loja(nameForSearch: item.name ?? "Local", coordinate: item.location.coordinate)
        // Se for uma loja/local já conhecido, abre ele (e não um pin duplicado)
        let local = localConhecido(correspondenteA: candidata) ?? candidata

        local.officialName = item.name
        local.category = item.pointOfInterestCategory?.rawValue
        local.address = item.address?.fullAddress
        local.fone = item.phoneNumber
        local.website = item.url?.absoluteString
        local.preencherEndereco(com: item)
        abrir(local)
    }

    // Fixados, favoritos e recentes
    private func selecionarLocalSalvo(_ loja: Loja) {
        abrir(localConhecido(correspondenteA: loja) ?? loja)
    }

    private func localConhecido(correspondenteA loja: Loja) -> Loja? {
        CorrespondenciaDeLocais.correspondente(loja, em: lojas)
            ?? CorrespondenciaDeLocais.correspondente(loja, em: locaisSalvos.locaisAvulsos)
    }

    // Caminho comum de busca, recentes e favoritos: fecha a busca primeiro e só depois
    // seleciona. Se a sheet for apresentada enquanto a barra de busca/teclado ainda estão
    // fechando, o iOS pode descartar a apresentação e o mapa mede uma altura errada.
    private func abrir(_ loja: Loja) {
        fecharBusca()
        // O pin do local pesquisado já precisa existir no mapa quando a seleção chegar
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
            detenteDaSheet = detenteReduzido
            if loja == lojaSelecionada {
                // onChange não dispara pra mesma loja, então foca manualmente
                if let mapProxyAtual {
                    focar(loja, mapProxy: mapProxyAtual, zoomPadrao: true, aguardarBarra: false)
                }
            } else {
                selecaoVeioDaBusca = true
                lojaSelecionada = loja
            }
        }
    }

    // MARK: - Mapa

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

    // Pin pronto pra desenhar: loja + visual já calculado
    private struct PinDesenhado: Identifiable {
        let loja: Loja
        let visual: MarcadorDoLocal
        // Ponto: centro na coordenada, sem nome embaixo. Pin: ponta na coordenada, com nome.
        let ehPonto: Bool
        var id: Loja.ID { loja.id }
    }

    private var mapa: some View {
        /*
         Os visuais são calculados AQUI, no body, e não dentro do ForEach/Annotation do Map:
         aqueles closures rodam depois, fora do body, e o SwiftUI não acompanha o estado lido
         lá dentro (favoritos, fixados, seleção). O pin ficava com o visual antigo.
        */
        let usaPontos = exibicao.usaPontos
        let pinsDesenhados = pinsNoMapa.map { loja in
            let selecionado = loja == lojaSelecionada
            return PinDesenhado(
                loja: loja,
                visual: MarcadorDoLocal(estilo: locaisSalvos.estilo(para: loja),
                                        selecionado: selecionado, comoPonto: usaPontos),
                ehPonto: usaPontos && !selecionado
            )
        }

        return MapReader { mapProxy in
            Map(
                position: $cameraPosition,
                bounds: MapCameraBounds(
                    centerCoordinateBounds: Config.regiaoMetropolitana,
                    minimumDistance: Config.distanciaMinima,
                    maximumDistance: Config.distanciaMaxima
                ),
                selection: $lojaSelecionada,
                scope: escopoDoMapa
            ) {
                UserAnnotation()

                // Lojas, favoritos/fixados avulsos e o local pesquisado, todos com o mesmo pin
                ForEach(pinsDesenhados) { pin in
                    let loja = pin.loja
                    Annotation(loja.nameForSearch, coordinate: loja.coordinate,
                               anchor: pin.ehPonto ? .center : .bottom) {
                        pin.visual
                    }
                    .annotationTitles(pin.ehPonto ? .hidden : .automatic)
                    // Sem a tag o Map não reconhece o pin como selecionado
                    .tag(loja)
                }

                ForEach(shopClusterManager.visibleGroups) { grupo in
                    Annotation("", coordinate: grupo.coordinate) {
                        BolhaDeAgrupamento(quantidade: grupo.count)
                            .onTapGesture {
                                fecharSheetAntes {
                                    aproximar(do: grupo)
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
                selecaoMudou(para: novaLoja, mapProxy: mapProxy)
            }
            .onChange(of: locator.currentLocalization) { _, novaLocalizacao in
                // Só posiciona no usuário na primeira localização; depois disso cada atualização
                // do GPS jogaria a câmera de volta pro usuário, desfazendo o foco na loja
                guard !jaCentralizouNoUsuario, lojaSelecionada == nil else { return }
                jaCentralizouNoUsuario = true
                cameraPosition = EnquadramentoDoMapa.cameraInicial(para: novaLocalizacao)
            }
            .task {
                shopClusterManager.agrupar = exibicao.agrupa
                SincronizacaoDeLojas.sincronizarCatalogo(em: modelContext)
                locaisSalvos.lojasCadastradas = lojas
                locaisSalvos.carregar()
                shopClusterManager.setLojas(lojas + locaisSalvos.locaisAvulsos)
                await shopClusterManager.updateClusters(mapProxy: mapProxy)

                if await SincronizacaoDeLojas.atualizarPelaInternet(em: modelContext) {
                    // Coordenadas podem ter mudado: refaz os clusters
                    atualizarLojasNoCluster(mapProxy: mapProxy)
                }
            }
            // Na primeira abertura as lojas só aparecem na @Query depois de gravadas
            .onChange(of: lojas) {
                locaisSalvos.lojasCadastradas = lojas
                atualizarLojasNoCluster(mapProxy: mapProxy)
            }
            .onChange(of: exibicao) {
                shopClusterManager.agrupar = exibicao.agrupa
                agendarAtualizacaoDosClusters(mapProxy: mapProxy)
            }
            // Favoritou/fixou (ou desfez) um local avulso: ele entra/sai do cluster
            .onChange(of: locaisSalvos.locaisAvulsos) {
                atualizarLojasNoCluster(mapProxy: mapProxy)
            }
            .onAppear {
                locator.requestLocation()
                mapProxyAtual = mapProxy
            }
            .sheet(isPresented: sheetAberta, onDismiss: {
                detenteDaSheet = detenteReduzido
            }) {
                sheetDeDetalhes
            }
        }
    }

    // MARK: - Clusters

    private func atualizarLojasNoCluster(mapProxy: MapProxy) {
        shopClusterManager.setLojas(lojas + locaisSalvos.locaisAvulsos)
        agendarAtualizacaoDosClusters(mapProxy: mapProxy)
    }

    private func agendarAtualizacaoDosClusters(mapProxy: MapProxy) {
        tarefaDeAtualizacao?.cancel()
        tarefaDeAtualizacao = Task {
            try? await Task.sleep(for: .seconds(0.3))
            guard !Task.isCancelled else { return }
            await shopClusterManager.updateClusters(mapProxy: mapProxy)
        }
    }

    private func aproximar(do grupo: GroupOfShops) {
        guard let enquadramento = EnquadramentoDoMapa.regiaoDoGrupo(grupo.lojas) else { return }
        if enquadramento.pertoDemais {
            shopClusterManager.forcarSeparacao(grupo.lojas)
        }
        withAnimation(.easeInOut(duration: 1.6)) {
            cameraPosition = .region(enquadramento.regiao)
        }
    }

    // MARK: - Seleção

    private func selecaoMudou(para novaLoja: Loja?, mapProxy: MapProxy) {
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
            detenteDaSheet = detenteReduzido
        }
        lojaDaSheet = loja

        let veioDaBusca = selecaoVeioDaBusca
        selecaoVeioDaBusca = false
        // Se a sheet estava fechada, a barra vai sumir agora; espera ela sumir pra medir
        // o mapa já no estado final (o MapKit reenquadra quando a área útil muda)
        focar(loja, mapProxy: mapProxy, zoomPadrao: veioDaBusca, aguardarBarra: sheetEstavaFechada)
        locaisSalvos.registrarRecente(loja)
    }

    private func focar(_ loja: Loja, mapProxy: MapProxy, zoomPadrao: Bool, aguardarBarra: Bool) {
        let cadastrada = lojas.contains(loja)
        let avulsoSalvo = locaisSalvos.ehLocalAvulsoSalvo(loja)
        // Local de busca (não cadastrado) fica em pontoPesquisado enquanto estiver selecionado
        pontoPesquisado = cadastrada ? nil : loja
        // O selecionado nunca fica escondido dentro de um cluster
        shopClusterManager.destacar(loja)
        agendarAtualizacaoDosClusters(mapProxy: mapProxy)
        // Toque no pin mantém o zoom do usuário; busca/recentes/favoritos (ou local avulso)
        // sempre vão pro mesmo zoom, aproximando ou afastando conforme o necessário
        // (pin de local salvo já está no mapa, então tocar nele se comporta como tocar numa loja)
        let usarZoomPadrao = zoomPadrao || !(cadastrada || avulsoSalvo)

        // Uma centralização por vez: toques rápidos cancelam a anterior
        tarefaDeFoco?.cancel()
        tarefaDeFoco = Task {
            if aguardarBarra {
                try? await Task.sleep(for: .milliseconds(300))
            }
            guard !Task.isCancelled, loja == lojaSelecionada else { return }
            centralizarAcimaDaSheet(loja, mapProxy: mapProxy, zoomPadrao: usarZoomPadrao)
        }
    }

    private func centralizarAcimaDaSheet(_ loja: Loja, mapProxy: MapProxy, zoomPadrao: Bool) {
        guard let foco = EnquadramentoDoMapa.focoAcimaDaSheet(
            em: loja.coordinate,
            regiaoAtual: currentRegion,
            tamanhoDoMapa: tamanhoMapa,
            mapProxy: mapProxy,
            zoomPadrao: zoomPadrao
        ) else { return }

        withAnimation(.easeInOut(duration: foco.manteveZoom ? 0.6 : 0.8)) {
            cameraPosition = .region(foco.regiao)
        }
    }

    private func limparSelecao(mapProxy: MapProxy) {
        tarefaDeFoco?.cancel()
        lojaDaSheet = nil
        // Reseta com a sheet fechada: mudar o detent no meio da apresentação às vezes é ignorado
        detenteDaSheet = detenteReduzido
        pontoPesquisado = nil
        shopClusterManager.destacar(nil)
        agendarAtualizacaoDosClusters(mapProxy: mapProxy)
    }

    // MARK: - Sheet

    @ViewBuilder
    private var sheetDeDetalhes: some View {
        if let loja = lojaDaSheet {
            LojaDetailView(
                loja: loja,
                chaveDoLocal: locaisSalvos.chave(para: loja),
                ehLojaCadastrada: lojas.contains(loja),
                ehFavorito: locaisSalvos.ehFavorito(loja),
                onToggleFavorito: { locaisSalvos.alternarFavorito(loja) },
                ehFixado: locaisSalvos.ehFixado(loja),
                onToggleFixado: { locaisSalvos.alternarFixado(loja) },
                localizacaoDoUsuario: locator.currentLocalization,
                onFechar: fecharSheet
            )
            .presentationDetents([detenteReduzido, .large], selection: $detenteDaSheet)
            .presentationDragIndicator(.visible)
            .presentationBackgroundInteraction(.enabled(upThrough: detenteReduzido))
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

    private func fecharSheet() {
        lojaDaSheet = nil
        lojaSelecionada = nil
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
}

#Preview {
    RecifeMapView()
        .modelContainer(for: appSchema, inMemory: true)
}
